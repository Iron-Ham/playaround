import Observation
import UIKit

protocol CategorySelectionViewControllerDelegate: AnyObject {
  func categorySelectionViewController(
    _ controller: CategorySelectionViewController, didSelectItemType itemType: ItemType)
}

final class CategorySelectionViewController: UIViewController {
  weak var delegate: CategorySelectionViewControllerDelegate?
  private var selectedItemType: ItemType = .foods  // Track current selection

  private let itemTypes = ItemType.allCases

  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    restorationIdentifier = "CategorySelectionViewController"
    setupUI()
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    selectCategory(AppState.shared.selectedCategory)
  }

  private func setupUI() {
    title = "Categories"
    view.backgroundColor = .systemBackground

    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  func selectCategory(_ itemType: ItemType) {
    selectedItemType = itemType

    // Update the table view selection if it exists
    if let index = itemTypes.firstIndex(of: itemType) {
      let indexPath = IndexPath(row: index, section: 0)
      tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
  }

  var currentSelectedCategory: ItemType {
    return selectedItemType
  }
}

// MARK: - UITableViewDataSource
extension CategorySelectionViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return itemTypes.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    let itemType = itemTypes[indexPath.row]

    var configuration = cell.defaultContentConfiguration()
    configuration.text = itemType.rawValue
    configuration.image = createEmojiImage(itemType.emoji)

    cell.contentConfiguration = configuration
    cell.accessoryType = .disclosureIndicator

    return cell
  }

  private func createEmojiImage(_ emoji: String) -> UIImage? {
    let size = CGSize(width: 30, height: 30)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .center

      let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 20),
        .paragraphStyle: paragraphStyle,
      ]

      let attributedString = NSAttributedString(string: emoji, attributes: attributes)
      let textRect = CGRect(x: 0, y: 5, width: size.width, height: size.height - 10)
      attributedString.draw(in: textRect)
    }
  }
}

// MARK: - UITableViewDelegate
extension CategorySelectionViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedItemType = itemTypes[indexPath.row]
    self.selectedItemType = selectedItemType  // Update internal state
    delegate?.categorySelectionViewController(self, didSelectItemType: selectedItemType)
  }
}

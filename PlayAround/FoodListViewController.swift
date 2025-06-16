import UIKit

protocol FoodListViewControllerDelegate: AnyObject {
  func foodListViewController(_ controller: FoodListViewController, didSelectFood food: FoodItem)
}

final class FoodListViewController: UIViewController {
  weak var delegate: FoodListViewControllerDelegate?

  private let foods = FoodItem.sampleFoods
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FoodCell")
    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

  private func setupUI() {
    title = "Favorite Foods"
    view.backgroundColor = .systemBackground

    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}

// MARK: - UITableViewDataSource
extension FoodListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return foods.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell", for: indexPath)
    let food = foods[indexPath.row]

    var configuration = cell.defaultContentConfiguration()
    configuration.text = food.name
    configuration.secondaryText = food.category
    configuration.image = UIImage(systemName: "circle.fill")?.withTintColor(
      .systemBlue, renderingMode: .alwaysOriginal)

    // Use emoji as a text overlay on the image
    let emojiLabel = UILabel()
    emojiLabel.text = food.emoji
    emojiLabel.font = .systemFont(ofSize: 20)
    emojiLabel.translatesAutoresizingMaskIntoConstraints = false

    cell.contentConfiguration = configuration
    cell.accessoryType = .disclosureIndicator

    return cell
  }
}

// MARK: - UITableViewDelegate
extension FoodListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let selectedFood = foods[indexPath.row]
    delegate?.foodListViewController(self, didSelectFood: selectedFood)
  }
}

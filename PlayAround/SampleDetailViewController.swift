import UIKit

class SampleDetailViewController: UIViewController {
  var selectedNumber: Int = 0 {
    didSet {
      updateUI()
    }
  }

  private let tableView = UITableView(frame: .zero, style: .insetGrouped)
  private var properties: [(title: String, value: String)] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Number Details"
    view.backgroundColor = .systemBackground

    setupNavigationBar()
    setupTableView()
    updateUI()
  }

  private func setupNavigationBar() {
    let pushSplitButton = UIBarButtonItem(
      title: "Split",
      style: .plain,
      target: self,
      action: #selector(pushAnotherSplitView)
    )

    navigationItem.rightBarButtonItem = pushSplitButton
  }

  private func setupTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.delegate = self
    tableView.dataSource = self

    // Register cells
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PropertyCell")
    tableView.register(NumberHeaderCell.self, forCellReuseIdentifier: "NumberHeaderCell")

    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  private func updateUI() {
    guard isViewLoaded else { return }

    title = "Number \(selectedNumber)"

    // Update properties data
    properties = [
      ("Value", "\(selectedNumber)"),
      ("Type", selectedNumber % 2 == 0 ? "Even" : "Odd"),
      ("Square", "\(selectedNumber * selectedNumber)"),
      ("Cube", "\(selectedNumber * selectedNumber * selectedNumber)"),
      ("Binary", String(selectedNumber, radix: 2)),
      ("Hexadecimal", String(selectedNumber, radix: 16).uppercased()),
    ]

    tableView.reloadData()
  }

  @objc private func pushAnotherSplitView() {
    let newListVC = SampleListViewController()
    let newDetailVC = SampleDetailViewController()
    newDetailVC.selectedNumber = selectedNumber

    // Create inspector view controller for iOS 26+
    let inspectorVC = createInspectorViewController()

    let splitVC = NavigableSplitViewController(
      primary: newListVC,
      secondary: newDetailVC,
      inspector: inspectorVC
    )
    splitVC.title = "Nested Split View"

    var currentParent = self.parent
    while currentParent != nil {
      if let parentSplitVC = currentParent as? NavigableSplitViewController {
        parentSplitVC.navigationController?.pushViewController(splitVC, animated: true)
        return
      }
      currentParent = currentParent?.parent
    }

    navigationController?.pushViewController(splitVC, animated: true)
  }

  private func createInspectorViewController() -> UIViewController {
    let inspectorVC = UIViewController()
    inspectorVC.view.backgroundColor = .systemBackground
    inspectorVC.title = "Inspector"

    let label = UILabel()
    label.text =
      "Inspector Panel\n\nNumber: \(selectedNumber)\n\nThis is a demonstration of the new iOS 26 inspector column feature."
    label.font = .preferredFont(forTextStyle: .body)
    label.textAlignment = .center
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false

    inspectorVC.view.addSubview(label)

    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: inspectorVC.view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: inspectorVC.view.centerYAnchor),
      label.leadingAnchor.constraint(
        greaterThanOrEqualTo: inspectorVC.view.leadingAnchor, constant: 20),
      label.trailingAnchor.constraint(
        lessThanOrEqualTo: inspectorVC.view.trailingAnchor, constant: -20),
    ])

    return inspectorVC
  }
}

// MARK: - UITableViewDataSource
extension SampleDetailViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2  // Header section + Properties section
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1  // Number header
    } else {
      return properties.count
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell =
        tableView.dequeueReusableCell(withIdentifier: "NumberHeaderCell", for: indexPath)
        as! NumberHeaderCell
      cell.configure(with: selectedNumber)
      return cell
    } else {
      let cell = UITableViewCell(style: .value1, reuseIdentifier: "PropertyCell")
      let property = properties[indexPath.row]
      cell.textLabel?.text = property.title
      cell.detailTextLabel?.text = property.value
      cell.accessoryType = .none
      cell.selectionStyle = .none
      return cell
    }
  }
}

// MARK: - UITableViewDelegate
extension SampleDetailViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return 120  // Header cell height
    } else {
      return UITableView.automaticDimension
    }
  }
}

// MARK: - NumberHeaderCell
class NumberHeaderCell: UITableViewCell {
  private let numberLabel = UILabel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    numberLabel.font = .systemFont(ofSize: 80, weight: .bold)
    numberLabel.textAlignment = .center
    numberLabel.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(numberLabel)

    NSLayoutConstraint.activate([
      numberLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      numberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      numberLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 20),
      numberLabel.bottomAnchor.constraint(
        lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),
    ])
  }

  func configure(with number: Int) {
    numberLabel.text = "\(number)"

    if number % 2 == 0 {
      numberLabel.textColor = .systemBlue
    } else {
      numberLabel.textColor = .systemGreen
    }
  }
}

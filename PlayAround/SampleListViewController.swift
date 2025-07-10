import UIKit

/// A sample list view controller that displays a list of numbers
class SampleListViewController: UIViewController {

  private let tableView = UITableView()

  private let numbers = Array(1...50) 

  var onNumberSelected: ((Int) -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Numbers List"
    view.backgroundColor = .systemBackground

    setupTableView()
  }

  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NumberCell")
    tableView.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}


extension SampleListViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numbers.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "NumberCell", for: indexPath)
    let number = numbers[indexPath.row]

    cell.textLabel?.text = "Number \(number)"
    cell.detailTextLabel?.text = "Tap to see details"
    cell.accessoryType = .disclosureIndicator

    if number % 2 == 0 {
      cell.textLabel?.textColor = .systemBlue
    } else {
      cell.textLabel?.textColor = .systemGreen
    }

    return cell
  }
}


extension SampleListViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let selectedNumber = numbers[indexPath.row]

    onNumberSelected?(selectedNumber)

    updateDetailViewIfNeeded(with: selectedNumber)
  }

  private func updateDetailViewIfNeeded(with number: Int) {
    let detailVC = SampleDetailViewController()
    detailVC.selectedNumber = number
    // Gets handled by our router
    if let split = navigationController?.parent as? UISplitViewController {
      split.showDetailViewController(detailVC, sender: nil)
    } else if let split = splitViewController {
      split.showDetailViewController(detailVC, sender: nil)
    } else {
      navigationController?.pushViewController(detailVC, animated: true)
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
}

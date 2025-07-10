import UIKit

/// A sample list view controller that displays a list of numbers
class SampleListViewController: UIViewController {
    
    private let tableView = UITableView()
    private let numbers = Array(1...50) // List of numbers 1 through 50
    
    /// Closure to handle when a number is selected
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

// MARK: - UITableViewDataSource

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
        
        // Add some visual styling
        if number % 2 == 0 {
            cell.textLabel?.textColor = .systemBlue
        } else {
            cell.textLabel?.textColor = .systemGreen
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SampleListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedNumber = numbers[indexPath.row]
        
        // Call the closure if it's set
        onNumberSelected?(selectedNumber)
        
        // If we're in a split view, try to update the detail view
        updateDetailViewIfNeeded(with: selectedNumber)
    }
    
    private func updateDetailViewIfNeeded(with number: Int) {
        // Find the split view controller in the parent hierarchy
        var currentParent = self.parent
        while currentParent != nil {
            if let splitVC = currentParent as? NavigableSplitViewController {
                // Create a new detail view controller and show it in secondary
                let detailVC = SampleDetailViewController()
                detailVC.selectedNumber = number
                
                // Use showInSecondary for navigation from primary
                splitVC.showInSecondary(detailVC, animated: true)
                break
            }
            currentParent = currentParent?.parent
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

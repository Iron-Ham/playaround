import UIKit

/// A sample detail view controller that displays information about a selected number
class SampleDetailViewController: UIViewController {
    
    var selectedNumber: Int = 0 {
        didSet {
            updateUI()
        }
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let numberLabel = UILabel()
    private let propertiesStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Number Details"
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupUI()
        updateUI()
    }
    
    private func setupNavigationBar() {
        // Add a button to push another split view
        let pushSplitButton = UIBarButtonItem(
            title: "Split",
            style: .plain,
            target: self,
            action: #selector(pushAnotherSplitView)
        )
        
        navigationItem.rightBarButtonItem = pushSplitButton
    }
    
    private func setupUI() {
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Configure number label
        numberLabel.font = .systemFont(ofSize: 80, weight: .bold)
        numberLabel.textAlignment = .center
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure properties stack view
        propertiesStackView.axis = .vertical
        propertiesStackView.spacing = 16
        propertiesStackView.alignment = .fill
        propertiesStackView.distribution = .fill
        propertiesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(numberLabel)
        contentView.addSubview(propertiesStackView)
        
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Number label constraints
            numberLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            numberLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Properties stack view constraints
            propertiesStackView.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 40),
            propertiesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            propertiesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            propertiesStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func updateUI() {
        guard isViewLoaded else { return }
        
        numberLabel.text = "\(selectedNumber)"
        title = "Number \(selectedNumber)"
        
        // Update number label color based on properties
        if selectedNumber % 2 == 0 {
            numberLabel.textColor = .systemBlue
        } else {
            numberLabel.textColor = .systemGreen
        }
        
        // Clear existing property views
        propertiesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add number properties
        addProperty("Value", value: "\(selectedNumber)")
        addProperty("Type", value: selectedNumber % 2 == 0 ? "Even" : "Odd")
        addProperty("Square", value: "\(selectedNumber * selectedNumber)")
        addProperty("Cube", value: "\(selectedNumber * selectedNumber * selectedNumber)")
        addProperty("Binary", value: String(selectedNumber, radix: 2))
        addProperty("Hexadecimal", value: String(selectedNumber, radix: 16).uppercased())
    }
    
    private func addProperty(_ title: String, value: String) {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .preferredFont(forTextStyle: .body)
        valueLabel.textColor = .secondaryLabel
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        propertiesStackView.addArrangedSubview(containerView)
    }
    
    // MARK: - Actions
    
    @objc private func pushAnotherSplitView() {
        // Create new instances of the list and detail view controllers
        let newListVC = SampleListViewController()
        let newDetailVC = SampleDetailViewController()
        newDetailVC.selectedNumber = selectedNumber // Start with the same number
        
        // Create a new NavigableSplitViewController
        let splitVC = NavigableSplitViewController(
            primary: newListVC,
            secondary: newDetailVC
        )
        splitVC.title = "Nested Split View"
        
        // Find the parent NavigableSplitViewController and push onto its navigation stack
        var currentParent = self.parent
        while currentParent != nil {
            if let parentSplitVC = currentParent as? NavigableSplitViewController {
                // Use pushViewController for navigation from secondary
                parentSplitVC.pushViewController(splitVC, animated: true)
                return
            }
            currentParent = currentParent?.parent
        }
        
        // Fallback: if no parent split view found, push directly onto navigation controller
        navigationController?.pushViewController(splitVC, animated: true)
    }
}

import UIKit

/// A simple demo view controller that shows a button to launch the split view demo
class SimpleDemoViewController: UIViewController {
    
    private let buttonTitle: String
    private let tabTitle: String
    
    init(tabTitle: String, buttonTitle: String = "Launch Split View Demo") {
        self.tabTitle = tabTitle
        self.buttonTitle = buttonTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = tabTitle
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = tabTitle
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.text = "This is the \(tabTitle) tab. You can launch the NavigableSplitViewController demo from here."
        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .secondaryLabel
        
        // Demo button
        let demoButton = UIButton(type: .system)
        demoButton.setTitle(buttonTitle, for: .normal)
        demoButton.setTitleColor(.white, for: .normal)
        demoButton.backgroundColor = .systemBlue
        demoButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        demoButton.layer.cornerRadius = 12
        demoButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        demoButton.addTarget(self, action: #selector(launchSplitViewDemo), for: .touchUpInside)
        
        // Add shadow
        demoButton.layer.shadowColor = UIColor.black.cgColor
        demoButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        demoButton.layer.shadowOpacity = 0.1
        demoButton.layer.shadowRadius = 4
        
        // Add views to stack
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(demoButton)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc private func launchSplitViewDemo() {
        let splitDemoVC = SplitViewDemoViewController()
        navigationController?.pushViewController(splitDemoVC, animated: true)
    }
}

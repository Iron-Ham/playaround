import UIKit

protocol InspectorDelegate: AnyObject {
  func didHideInspector()
}

class InspectorViewController: UIViewController {
  private let selectedNumber: Int
  private let contentLabel = UILabel()
  weak var delegate: InspectorDelegate?

  init(selectedNumber: Int, delegate: InspectorDelegate?) {
    self.selectedNumber = selectedNumber
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

  private func setupUI() {
    view.backgroundColor = .systemBackground
    title = "Inspector"

    // Add trailing bar button item
    let hideButton = UIBarButtonItem(
      image: UIImage(systemName: "info.circle"),
      style: .plain,
      target: self,
      action: #selector(hideInspectorTapped)
    )
    if #available(iOS 26.0, *) {
      navigationItem.rightBarButtonItem = hideButton
    }

    contentLabel.text =
      "Inspector Panel\n\nNumber: \(selectedNumber)\n\nThis is a demonstration of the new iOS 26 inspector column feature."
    contentLabel.font = .preferredFont(forTextStyle: .body)
    contentLabel.textAlignment = .center
    contentLabel.numberOfLines = 0
    contentLabel.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(contentLabel)

    NSLayoutConstraint.activate([
      contentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      contentLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      contentLabel.leadingAnchor.constraint(
        greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
      contentLabel.trailingAnchor.constraint(
        lessThanOrEqualTo: view.trailingAnchor, constant: -20),
    ])
  }

  @objc private func hideInspectorTapped() {
    if #available(iOS 26.0, *) {
      splitViewController?.hide(.inspector)
      delegate?.didHideInspector()
    }
  }

  func updateSelectedNumber(_ number: Int) {
    contentLabel.text =
      "Inspector Panel\n\nNumber: \(number)\n\nThis is a demonstration of the new iOS 26 inspector column feature."
  }
}

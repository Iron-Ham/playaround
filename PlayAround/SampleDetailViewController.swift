import UIKit

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
    let pushSplitButton = UIBarButtonItem(
      title: "Split",
      style: .plain,
      target: self,
      action: #selector(pushAnotherSplitView)
    )

    navigationItem.rightBarButtonItem = pushSplitButton
  }

  private func setupUI() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(scrollView)
    scrollView.addSubview(contentView)

    numberLabel.font = .systemFont(ofSize: 80, weight: .bold)
    numberLabel.textAlignment = .center
    numberLabel.translatesAutoresizingMaskIntoConstraints = false

    propertiesStackView.axis = .vertical
    propertiesStackView.spacing = 16
    propertiesStackView.alignment = .fill
    propertiesStackView.distribution = .fill
    propertiesStackView.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(numberLabel)
    contentView.addSubview(propertiesStackView)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

      numberLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
      numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      numberLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

      propertiesStackView.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 40),
      propertiesStackView.leadingAnchor.constraint(
        equalTo: contentView.leadingAnchor, constant: 20),
      propertiesStackView.trailingAnchor.constraint(
        equalTo: contentView.trailingAnchor, constant: -20),
      propertiesStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
    ])
  }

  private func updateUI() {
    guard isViewLoaded else { return }

    numberLabel.text = "\(selectedNumber)"
    title = "Number \(selectedNumber)"

    if selectedNumber % 2 == 0 {
      numberLabel.textColor = .systemBlue
    } else {
      numberLabel.textColor = .systemGreen
    }

    propertiesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

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
      valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
    ])

    propertiesStackView.addArrangedSubview(containerView)
  }

  @objc private func pushAnotherSplitView() {
    let newListVC = SampleListViewController()
    let newDetailVC = SampleDetailViewController()
    newDetailVC.selectedNumber = selectedNumber

    let splitVC = NavigableSplitViewController(
      primary: newListVC,
      secondary: newDetailVC
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
}

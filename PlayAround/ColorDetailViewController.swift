import UIKit

final class ColorDetailViewController: UIViewController {
  private var colorItem: ColorItem?

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    return scrollView
  }()

  private lazy var contentStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 20
    stackView.alignment = .center
    return stackView
  }()

  private lazy var colorCircleView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 60
    view.layer.borderWidth = 2
    view.layer.borderColor = UIColor.systemGray3.cgColor
    return view
  }()

  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 32, weight: .bold)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()

  private lazy var categoryHexLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 18, weight: .medium)
    label.textAlignment = .center
    label.textColor = .systemBlue
    label.numberOfLines = 0
    return label
  }()

  private lazy var hexValueLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16, weight: .semibold)
    label.textAlignment = .center
    label.textColor = .secondaryLabel
    label.backgroundColor = .secondarySystemBackground
    label.layer.cornerRadius = 8
    label.layer.masksToBounds = true
    return label
  }()

  private lazy var descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16)
    label.textAlignment = .justified
    label.numberOfLines = 0
    label.textColor = .label
    return label
  }()

  var currentColor: ColorItem? {
    return colorItem
  }

  // MARK: - State Restoration

  private enum RestorationKeys {
    static let selectedColorID = "selectedColorID"
  }

  override func encodeRestorableState(with coder: NSCoder) {
    super.encodeRestorableState(with: coder)

    if let colorItem = colorItem {
      coder.encode(colorItem.id.uuidString, forKey: RestorationKeys.selectedColorID)
    }
  }

  override func decodeRestorableState(with coder: NSCoder) {
    super.decodeRestorableState(with: coder)

    if let colorID = coder.decodeObject(forKey: RestorationKeys.selectedColorID) as? String,
      let color = ColorItem.sampleColors.first(where: { $0.id.uuidString == colorID })
    {
      configure(with: color)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    restorationIdentifier = "ColorDetailViewController"
    setupUI()
    updateContent()
  }

  private func setupUI() {
    view.backgroundColor = .systemBackground

    view.addSubview(scrollView)
    scrollView.addSubview(contentStackView)

    contentStackView.addArrangedSubview(colorCircleView)
    contentStackView.addArrangedSubview(nameLabel)
    contentStackView.addArrangedSubview(categoryHexLabel)
    contentStackView.addArrangedSubview(hexValueLabel)

    // Add some spacing before description
    let spacerView = UIView()
    spacerView.heightAnchor.constraint(equalToConstant: 10).isActive = true
    contentStackView.addArrangedSubview(spacerView)

    contentStackView.addArrangedSubview(descriptionLabel)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
      contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
      contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
      contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
      contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),

      colorCircleView.widthAnchor.constraint(equalToConstant: 120),
      colorCircleView.heightAnchor.constraint(equalToConstant: 120),

      hexValueLabel.widthAnchor.constraint(equalToConstant: 100),
      hexValueLabel.heightAnchor.constraint(equalToConstant: 30),

      descriptionLabel.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
      descriptionLabel.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
    ])
  }

  func configure(with colorItem: ColorItem) {
    self.colorItem = colorItem
    if isViewLoaded {
      updateContent()
    }
  }

  private func updateContent() {
    guard let colorItem = colorItem else {
      showPlaceholder()
      return
    }

    title = colorItem.name
    colorCircleView.backgroundColor = colorItem.color
    nameLabel.text = colorItem.name
    categoryHexLabel.text = colorItem.category
    hexValueLabel.text = colorItem.hexValue
    descriptionLabel.text = colorItem.description
  }

  private func showPlaceholder() {
    title = "Color Details"
    colorCircleView.backgroundColor = .systemGray3
    nameLabel.text = "Select a Color"
    categoryHexLabel.text = "Choose from the list"
    hexValueLabel.text = "#000000"
    descriptionLabel.text = "Select a color from the list to see its beautiful details here!"
  }
}

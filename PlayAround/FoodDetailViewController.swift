import UIKit

final class FoodDetailViewController: UIViewController {
  private var food: FoodItem?

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

  private lazy var emojiLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 80)
    label.textAlignment = .center
    return label
  }()

  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 32, weight: .bold)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()

  private lazy var categoryOriginLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 18, weight: .medium)
    label.textAlignment = .center
    label.textColor = .systemBlue
    label.numberOfLines = 0
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

  var currentFood: FoodItem? {
    return food
  }

  // MARK: - State Restoration

  private enum RestorationKeys {
    static let selectedFoodID = "selectedFoodID"
  }

  override func encodeRestorableState(with coder: NSCoder) {
    super.encodeRestorableState(with: coder)

    if let food = food {
      coder.encode(food.id.uuidString, forKey: RestorationKeys.selectedFoodID)
    }
  }

  override func decodeRestorableState(with coder: NSCoder) {
    super.decodeRestorableState(with: coder)

    if let foodID = coder.decodeObject(forKey: RestorationKeys.selectedFoodID) as? String,
      let food = FoodItem.sampleFoods.first(where: { $0.id.uuidString == foodID })
    {
      configure(with: food)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    restorationIdentifier = "FoodDetailViewController"
    setupUI()
    updateContent()
  }

  private func setupUI() {
    view.backgroundColor = .systemBackground

    view.addSubview(scrollView)
    scrollView.addSubview(contentStackView)

    contentStackView.addArrangedSubview(emojiLabel)
    contentStackView.addArrangedSubview(nameLabel)
    contentStackView.addArrangedSubview(categoryOriginLabel)

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

      descriptionLabel.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
      descriptionLabel.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
    ])
  }

  func configure(with food: FoodItem) {
    self.food = food
    if isViewLoaded {
      updateContent()
    }
  }

  private func updateContent() {
    guard let food = food else {
      showPlaceholder()
      return
    }

    title = food.name
    emojiLabel.text = food.emoji
    nameLabel.text = food.name
    categoryOriginLabel.text = "\(food.category) • \(food.origin)"
    descriptionLabel.text = food.description
  }

  private func showPlaceholder() {
    title = "Food Details"
    emojiLabel.text = "🍽️"
    nameLabel.text = "Select a Food"
    categoryOriginLabel.text = "Choose from the list"
    descriptionLabel.text = "Select a food item from the list to see its delicious details here!"
  }
}

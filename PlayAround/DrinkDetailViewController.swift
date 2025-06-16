import UIKit

final class DrinkDetailViewController: UIViewController {
  private var drink: DrinkItem?

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

  var currentDrink: DrinkItem? {
    return drink
  }

  // MARK: - State Restoration

  private enum RestorationKeys {
    static let selectedDrinkID = "selectedDrinkID"
  }

  override func encodeRestorableState(with coder: NSCoder) {
    super.encodeRestorableState(with: coder)

    if let drink = drink {
      coder.encode(drink.id.uuidString, forKey: RestorationKeys.selectedDrinkID)
    }
  }

  override func decodeRestorableState(with coder: NSCoder) {
    super.decodeRestorableState(with: coder)

    if let drinkID = coder.decodeObject(forKey: RestorationKeys.selectedDrinkID) as? String,
      let drink = DrinkItem.sampleDrinks.first(where: { $0.id.uuidString == drinkID })
    {
      configure(with: drink)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    restorationIdentifier = "DrinkDetailViewController"
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

  func configure(with drink: DrinkItem) {
    self.drink = drink
    if isViewLoaded {
      updateContent()
    }
  }

  private func updateContent() {
    guard let drink = drink else {
      showPlaceholder()
      return
    }

    title = drink.name
    emojiLabel.text = drink.emoji
    nameLabel.text = drink.name
    categoryOriginLabel.text = "\(drink.category) • \(drink.origin)"
    descriptionLabel.text = drink.description
  }

  private func showPlaceholder() {
    title = "Drink Details"
    emojiLabel.text = "🥤"
    nameLabel.text = "Select a Drink"
    categoryOriginLabel.text = "Choose from the list"
    descriptionLabel.text = "Select a drink item from the list to see its refreshing details here!"
  }
}

import UIKit

enum ItemType: String, CaseIterable {
  case foods = "Favorite Foods"
  case drinks = "Favorite Drinks"
  case colors = "Favorite Colors"
  case profile = "My Profile"

  var emoji: String {
    switch self {
    case .foods: return "🍽️"
    case .drinks: return "🥤"
    case .colors: return "🎨"
    case .profile: return "👤"
    }
  }
}

protocol ItemListViewControllerDelegate: AnyObject {
  func itemListViewController(_ controller: ItemListViewController, didSelectFood food: FoodItem)
  func itemListViewController(_ controller: ItemListViewController, didSelectDrink drink: DrinkItem)
  func itemListViewController(_ controller: ItemListViewController, didSelectColor color: ColorItem)
  func itemListViewController(_ controller: ItemListViewController, didSelectProfile: Void)
}

final class ItemListViewController: UIViewController {
  weak var delegate: ItemListViewControllerDelegate?

  private var currentItemType: ItemType = .foods
  private let foods = FoodItem.sampleFoods
  private let drinks = DrinkItem.sampleDrinks
  private let colors = ColorItem.sampleColors

  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.delegate = self
    tableView.dataSource = self

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ItemCell")
    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    restorationIdentifier = "ItemListViewController"
    setupUI()
    updateContent()
  }

  private func setupUI() {
    view.backgroundColor = .systemBackground
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  func configure(with itemType: ItemType) {
    self.currentItemType = itemType
    updateContent()
  }

  private func updateContent() {
    title = currentItemType.rawValue
    if isViewLoaded {
      tableView.reloadData()
    }
  }
}

// MARK: - UITableViewDataSource
extension ItemListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch currentItemType {
    case .foods: return foods.count
    case .drinks: return drinks.count
    case .colors: return colors.count
    case .profile: return 1  // Single profile row
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
    var configuration = cell.defaultContentConfiguration()

    switch currentItemType {
    case .foods:
      let food = foods[indexPath.row]
      configuration.text = food.name
      configuration.secondaryText = food.category
      configuration.image = createEmojiImage(food.emoji)

    case .drinks:
      let drink = drinks[indexPath.row]
      configuration.text = drink.name
      configuration.secondaryText = drink.category
      configuration.image = createEmojiImage(drink.emoji)

    case .colors:
      let color = colors[indexPath.row]
      configuration.text = color.name
      configuration.secondaryText = "\(color.category) • \(color.hexValue)"
      configuration.image = createColorImage(color.color)

    case .profile:
      configuration.text = "View Profile"
      configuration.secondaryText = "Your personal information"
      configuration.image = createEmojiImage("👤")
    }

    cell.contentConfiguration = configuration
    cell.accessoryType = .disclosureIndicator

    return cell
  }

  private func createEmojiImage(_ emoji: String) -> UIImage? {
    let size = CGSize(width: 30, height: 30)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .center

      let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 20),
        .paragraphStyle: paragraphStyle,
      ]

      let attributedString = NSAttributedString(string: emoji, attributes: attributes)
      let textRect = CGRect(x: 0, y: 5, width: size.width, height: size.height - 10)
      attributedString.draw(in: textRect)
    }
  }

  private func createColorImage(_ color: UIColor) -> UIImage? {
    let size = CGSize(width: 30, height: 30)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
      let rect = CGRect(origin: .zero, size: size)

      // Fill with the color
      color.setFill()
      context.cgContext.fillEllipse(in: rect)

      // Add a border
      UIColor.systemGray3.setStroke()
      context.cgContext.setLineWidth(1)
      context.cgContext.strokeEllipse(in: rect)
    }
  }
}

// MARK: - UITableViewDelegate
extension ItemListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    switch currentItemType {
    case .foods:
      let selectedFood = foods[indexPath.row]
      delegate?.itemListViewController(self, didSelectFood: selectedFood)

    case .drinks:
      let selectedDrink = drinks[indexPath.row]
      delegate?.itemListViewController(self, didSelectDrink: selectedDrink)

    case .colors:
      let selectedColor = colors[indexPath.row]
      delegate?.itemListViewController(self, didSelectColor: selectedColor)

    case .profile:
      delegate?.itemListViewController(self, didSelectProfile: ())
    }
  }
}

// MARK: - State Restoration
extension ItemListViewController {
  private enum RestorationKeys {
    static let currentItemType = "currentItemType"
  }

  override func encodeRestorableState(with coder: NSCoder) {
    super.encodeRestorableState(with: coder)
    coder.encode(currentItemType.rawValue, forKey: RestorationKeys.currentItemType)
  }

  override func decodeRestorableState(with coder: NSCoder) {
    super.decodeRestorableState(with: coder)

    if let itemTypeRawValue = coder.decodeObject(forKey: RestorationKeys.currentItemType)
      as? String,
      let itemType = ItemType(rawValue: itemTypeRawValue)
    {
      configure(with: itemType)
    }
  }
}

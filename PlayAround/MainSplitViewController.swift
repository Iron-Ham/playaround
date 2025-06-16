import Observation
import UIKit

final class MainSplitViewController: UISplitViewController {

  private let categorySelectionViewController = CategorySelectionViewController()
  private let itemListViewController = ItemListViewController()
  private let foodDetailViewController = FoodDetailViewController()
  private let drinkDetailViewController = DrinkDetailViewController()
  private let colorDetailViewController = ColorDetailViewController()
  private let userProfileViewController = UserProfileViewController()

  private var currentDetailViewController: UIViewController?
  private let compactTabBarController = CompactTabBarController()

  init() {
    super.init(style: .tripleColumn)
    preferredDisplayMode = .oneBesideSecondary
    showsSecondaryOnlyButton = true

    restorationIdentifier = "MainSplitViewController"
    delegate = self

    setupViewControllers()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    categorySelectionViewController.selectCategory(AppState.shared.selectedCategory)
    switch AppState.shared.selectedCategory {
    case .foods:
      switchToDetailViewController(foodDetailViewController)
    case .drinks:
      switchToDetailViewController(drinkDetailViewController)
    case .colors:
      switchToDetailViewController(colorDetailViewController)
    case .profile:
      switchToDetailViewController(userProfileViewController)
    }

    itemListViewController.configure(with: AppState.shared.selectedCategory)

    if let color = AppState.shared.selectedColor {
      colorDetailViewController.configure(with: color)
    }

    if let food = AppState.shared.selectedFood {
      foodDetailViewController.configure(with: food)
    }

    if let drink = AppState.shared.selectedDrink {
      drinkDetailViewController.configure(with: drink)
    }
  }

  private func setupViewControllers() {
    // Set up the category selection as the primary view controller
    let primaryNavController = UINavigationController(
      rootViewController: categorySelectionViewController)
    primaryNavController.restorationIdentifier = "PrimaryNavController"
    categorySelectionViewController.delegate = self

    // Set up the detail view controller as the secondary view controller
    let secondaryNavController = UINavigationController(
      rootViewController: foodDetailViewController)
    secondaryNavController.restorationIdentifier = "SecondaryNavController"
    currentDetailViewController = foodDetailViewController

    // Set up the item list as the supplementary view controller
    let supplementaryNavController = UINavigationController(
      rootViewController: itemListViewController)
    supplementaryNavController.restorationIdentifier = "SupplementaryNavController"
    itemListViewController.delegate = self

    // Configure the split view controller for regular size classes
    setViewController(primaryNavController, for: .primary)
    setViewController(secondaryNavController, for: .secondary)
    setViewController(supplementaryNavController, for: .supplementary)

    // Set up the compact view controller - system will show this automatically in compact size classes
    setViewController(compactTabBarController, for: .compact)

    // Set preferred column widths
    preferredPrimaryColumnWidth = 250
    preferredSupplementaryColumnWidth = 400
    minimumPrimaryColumnWidth = 200
    minimumSupplementaryColumnWidth = 300
    maximumSupplementaryColumnWidth = 500

    // Start with foods selected by default
    AppState.shared.selectCategory(.foods)
  }

  private func switchToDetailViewController(_ newDetailViewController: UIViewController) {
    guard
      let secondaryNavController = viewController(for: .secondary)
        as? UINavigationController
    else {
      return
    }

    // Only switch if it's a different view controller
    if currentDetailViewController !== newDetailViewController {
      secondaryNavController.setViewControllers([newDetailViewController], animated: false)
      currentDetailViewController = newDetailViewController
    }
  }
}

// MARK: - CategorySelectionViewControllerDelegate
extension MainSplitViewController: CategorySelectionViewControllerDelegate {
  func categorySelectionViewController(
    _ controller: CategorySelectionViewController, didSelectItemType itemType: ItemType
  ) {
    AppState.shared.selectCategory(itemType)
    itemListViewController.configure(with: itemType)
    let detail =
      switch itemType {
      case .colors:
        colorDetailViewController
      case .drinks:
        drinkDetailViewController
      case .foods:
        foodDetailViewController
      case .profile:
        userProfileViewController
      }
    switchToDetailViewController(detail)
  }
}

// MARK: - ItemListViewControllerDelegate
extension MainSplitViewController: ItemListViewControllerDelegate {
  func itemListViewController(_ controller: ItemListViewController, didSelectFood food: FoodItem) {
    AppState.shared.selectFood(food)
  }

  func itemListViewController(_ controller: ItemListViewController, didSelectDrink drink: DrinkItem)
  {
    AppState.shared.selectDrink(drink)
  }

  func itemListViewController(_ controller: ItemListViewController, didSelectColor color: ColorItem)
  {
    AppState.shared.selectColor(color)
  }

  func itemListViewController(_ controller: ItemListViewController, didSelectProfile: Void) {
    AppState.shared.selectProfile()
  }
}

// MARK: - UISplitViewControllerDelegate
extension MainSplitViewController: UISplitViewControllerDelegate {

  func splitViewController(
    _ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode
  ) {
    // Update layout state for tracking
    AppState.shared.isCompactLayout = (traitCollection.horizontalSizeClass == .compact)
  }
}

// MARK: - State Preservation & Restoration
extension MainSplitViewController {

  // Legacy conversion methods are no longer needed with global AppState

  private enum RestorationKeys {
    static let selectedCategory = "selectedCategory"
    static let selectedFoodID = "selectedFoodID"
    static let selectedDrinkID = "selectedDrinkID"
    static let selectedColorID = "selectedColorID"
    static let isCompactMode = "isCompactMode"
  }

  override func encodeRestorableState(with coder: NSCoder) {
    super.encodeRestorableState(with: coder)

    let appState = AppState.shared

    // Encode current state from global app state
    coder.encode(appState.selectedCategory.rawValue, forKey: RestorationKeys.selectedCategory)

    // Encode selected items by their IDs
    if let selectedFood = appState.selectedFood {
      coder.encode(selectedFood.id.uuidString, forKey: RestorationKeys.selectedFoodID)
    }
    if let selectedDrink = appState.selectedDrink {
      coder.encode(selectedDrink.id.uuidString, forKey: RestorationKeys.selectedDrinkID)
    }
    if let selectedColor = appState.selectedColor {
      coder.encode(selectedColor.id.uuidString, forKey: RestorationKeys.selectedColorID)
    }

    // Encode layout state
    coder.encode(appState.isCompactLayout, forKey: RestorationKeys.isCompactMode)
  }

  override func decodeRestorableState(with coder: NSCoder) {
    super.decodeRestorableState(with: coder)

    // Decode the selected category
    guard
      let categoryRawValue = coder.decodeObject(forKey: RestorationKeys.selectedCategory)
        as? String,
      let selectedCategory = ItemType(rawValue: categoryRawValue)
    else {
      return
    }

    // Decode selected item IDs
    let selectedFoodID = coder.decodeObject(forKey: RestorationKeys.selectedFoodID) as? String
    let selectedDrinkID = coder.decodeObject(forKey: RestorationKeys.selectedDrinkID) as? String
    let selectedColorID = coder.decodeObject(forKey: RestorationKeys.selectedColorID) as? String
    let wasInCompactMode = coder.decodeBool(forKey: RestorationKeys.isCompactMode)

    // Find the actual items from the IDs
    let selectedFood = selectedFoodID.flatMap { id in
      FoodItem.sampleFoods.first { $0.id.uuidString == id }
    }
    let selectedDrink = selectedDrinkID.flatMap { id in
      DrinkItem.sampleDrinks.first { $0.id.uuidString == id }
    }
    let selectedColor = selectedColorID.flatMap { id in
      ColorItem.sampleColors.first { $0.id.uuidString == id }
    }

    // Restore the state to global app state after the view loads
    DispatchQueue.main.async {
      AppState.shared.restoreState(
        category: selectedCategory,
        food: selectedFood,
        drink: selectedDrink,
        color: selectedColor
      )
      AppState.shared.isCompactLayout = wasInCompactMode
    }
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    // Update layout state for tracking
    if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
      AppState.shared.isCompactLayout = (traitCollection.horizontalSizeClass == .compact)
    }
  }
}

#Preview {
  MainSplitViewController()
}

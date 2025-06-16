import Observation
import UIKit

final class CompactTabBarController: UITabBarController {

  private let foodsListViewController = ItemListViewController()
  private let drinksListViewController = ItemListViewController()
  private let colorsListViewController = ItemListViewController()
  private let userProfileViewController = UserProfileViewController()

  // Detail view controllers
  private let foodDetailViewController = FoodDetailViewController()
  private let drinkDetailViewController = DrinkDetailViewController()
  private let colorDetailViewController = ColorDetailViewController()

  private var currentDetailViewController: UIViewController?

  private enum RestorationKeys {
    static let selectedCategory = "selectedCategory"
    static let selectedFoodID = "selectedFoodID"
    static let selectedDrinkID = "selectedDrinkID"
    static let selectedColorID = "selectedColorID"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    restorationIdentifier = "CompactTabBarController"
    setupTabs()
    setupDelegates()
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    handleStateChange()
  }

  private func setupTabs() {
    // Foods Tab
    foodsListViewController.configure(with: .foods)
    let foodsNavController = UINavigationController(rootViewController: foodsListViewController)
    foodsNavController.restorationIdentifier = "FoodsTabNavController"
    foodsNavController.tabBarItem = UITabBarItem(
      title: "Foods",
      image: UIImage(systemName: "fork.knife"),
      selectedImage: UIImage(systemName: "fork.knife.circle.fill")
    )

    // Drinks Tab
    drinksListViewController.configure(with: .drinks)
    let drinksNavController = UINavigationController(rootViewController: drinksListViewController)
    drinksNavController.restorationIdentifier = "DrinksTabNavController"
    drinksNavController.tabBarItem = UITabBarItem(
      title: "Drinks",
      image: UIImage(systemName: "cup.and.saucer"),
      selectedImage: UIImage(systemName: "cup.and.saucer.fill")
    )

    // Colors Tab
    colorsListViewController.configure(with: .colors)
    let colorsNavController = UINavigationController(rootViewController: colorsListViewController)
    colorsNavController.restorationIdentifier = "ColorsTabNavController"
    colorsNavController.tabBarItem = UITabBarItem(
      title: "Colors",
      image: UIImage(systemName: "paintpalette"),
      selectedImage: UIImage(systemName: "paintpalette.fill")
    )

    // Profile Tab
    let profileNavController = UINavigationController(rootViewController: userProfileViewController)
    profileNavController.restorationIdentifier = "ProfileTabNavController"
    profileNavController.tabBarItem = UITabBarItem(
      title: "Profile",
      image: UIImage(systemName: "person"),
      selectedImage: UIImage(systemName: "person.fill")
    )

    viewControllers = [
      foodsNavController, drinksNavController, colorsNavController, profileNavController,
    ]

    // Start with foods tab selected
    selectedIndex = 0
    currentDetailViewController = foodDetailViewController
  }

  private func setupDelegates() {
    foodsListViewController.delegate = self
    drinksListViewController.delegate = self
    colorsListViewController.delegate = self
  }

  private func pushDetailViewController(_ detailViewController: UIViewController) {
    // Get the current tab's navigation controller
    guard let selectedNavController = selectedViewController as? UINavigationController,
      !selectedNavController.viewControllers.contains(where: { $0 === detailViewController })
    else { return }

    // Push the detail view controller onto the navigation stack
    selectedNavController.pushViewController(detailViewController, animated: true)
    currentDetailViewController = detailViewController
  }
}

// MARK: - State Preservation & Restoration
extension CompactTabBarController {

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
  }

  override func decodeRestorableState(with coder: NSCoder) {
    super.decodeRestorableState(with: coder)

    // The global app state will handle restoration, so we don't need
    // to duplicate the restoration logic here
  }
}

// MARK: - AppStateObserver
extension CompactTabBarController {
  func handleStateChange() {
    let appState = AppState.shared

    // Update tab selection
    switch appState.selectedCategory {
    case .foods: selectedIndex = 0
    case .drinks: selectedIndex = 1
    case .colors: selectedIndex = 2
    case .profile: selectedIndex = 3
    }

    // Update detail views based on selection
    if let selectedFood = appState.selectedFood {
      foodDetailViewController.configure(with: selectedFood)
      if selectedIndex == 0 {  // Foods tab
        pushDetailViewController(foodDetailViewController)
      }
    } else if let selectedDrink = appState.selectedDrink {
      drinkDetailViewController.configure(with: selectedDrink)
      if selectedIndex == 1 {  // Drinks tab
        pushDetailViewController(drinkDetailViewController)
      }
    } else if let selectedColor = appState.selectedColor {
      colorDetailViewController.configure(with: selectedColor)
      if selectedIndex == 2 {  // Colors tab
        pushDetailViewController(colorDetailViewController)
      }
    }
  }
}

// MARK: - ItemListViewControllerDelegate
extension CompactTabBarController: ItemListViewControllerDelegate {
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

#Preview {
  CompactTabBarController()
}

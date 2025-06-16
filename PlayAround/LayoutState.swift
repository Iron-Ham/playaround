import Foundation
import Observation

// MARK: - Tab Type
enum TabType: Int, CaseIterable, Identifiable {
  case foods
  case drinks
  case colors
  case profile

  var id: Int { rawValue }

  var name: String {
    switch self {
    case .foods: return "Favorite Foods"
    case .drinks: return "Favorite Drinks"
    case .colors: return "Favorite Colors"
    case .profile: return "My Profile"
    }
  }

  var emoji: String {
    switch self {
    case .foods: return "🍽️"
    case .drinks: return "🥤"
    case .colors: return "🎨"
    case .profile: return "👤"
    }
  }
}

// MARK: - Global App State
@Observable
@MainActor
class AppState {
  static let shared = AppState()

  // Current selection state
  var selectedTab: TabType = .foods
  var selectedFood: FoodItem?
  var selectedDrink: DrinkItem?
  var selectedColor: ColorItem?

  // Layout state
  var isCompactLayout: Bool = false

  private init() {}

  // MARK: - State Updates
  // Note: These methods preserve unrelated selections to minimize unnecessary updates
  // and provide better user experience by maintaining context across category switches

  func selectTab(_ tab: TabType) {
    selectedTab = tab
    // Only clear selections that are no longer relevant
    if tab != .foods { selectedFood = nil }
    if tab != .drinks { selectedDrink = nil }
    if tab != .colors { selectedColor = nil }
  }

  func selectFood(_ food: FoodItem) {
    selectedTab = .foods
    selectedFood = food
    // Preserve drink/color selections - they're unrelated
  }

  func selectDrink(_ drink: DrinkItem) {
    selectedTab = .drinks
    selectedDrink = drink
    // Preserve food/color selections - they're unrelated
  }

  func selectColor(_ color: ColorItem) {
    selectedTab = .colors
    selectedColor = color
    // Preserve food/drink selections - they're unrelated
  }

  func selectProfile() {
    selectedTab = .profile
    // Preserve other selections - they're unrelated to profile
  }

  // MARK: - Current Selection
  var currentTab: TabType {
    return selectedTab
  }

  // MARK: - State Restoration Support
  func restoreState(
    tab: TabType, food: FoodItem? = nil, drink: DrinkItem? = nil, color: ColorItem? = nil
  ) {
    selectedTab = tab
    selectedFood = food
    selectedDrink = drink
    selectedColor = color
  }

  // Backward compatibility for restoration
  func restoreState(
    category: ItemType, food: FoodItem? = nil, drink: DrinkItem? = nil, color: ColorItem? = nil
  ) {
    let tab: TabType =
      switch category {
      case .foods: .foods
      case .drinks: .drinks
      case .colors: .colors
      case .profile: .profile
      }
    restoreState(tab: tab, food: food, drink: drink, color: color)
  }

  // MARK: - Backward Compatibility
  // TODO: Remove after updating all references to use TabType
  var selectedCategory: ItemType {
    get {
      switch selectedTab {
      case .foods: return .foods
      case .drinks: return .drinks
      case .colors: return .colors
      case .profile: return .profile
      }
    }
    set {
      switch newValue {
      case .foods: selectedTab = .foods
      case .drinks: selectedTab = .drinks
      case .colors: selectedTab = .colors
      case .profile: selectedTab = .profile
      }
    }
  }

  func selectCategory(_ category: ItemType) {
    switch category {
    case .foods: selectTab(.foods)
    case .drinks: selectTab(.drinks)
    case .colors: selectTab(.colors)
    case .profile: selectTab(.profile)
    }
  }
}

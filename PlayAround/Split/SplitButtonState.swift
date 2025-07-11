import UIKit

struct SplitButtonState: Hashable {
  let isBackButtonVisible: Bool
  let isSidebarLeftVisible: Bool
  let isSidebarTrailingVisible: Bool
}

extension NavigableSplitViewController {
  var secondaryNavHasBackStack: Bool {
    if let secondaryNavController = secondaryVC as? UINavigationController,
       secondaryNavController.viewControllers.count > 1 {
      true
    } else {
      false
    }
  }

  var primaryNavHasBackStack: Bool {
    if let primaryNavController = primaryVC as? UINavigationController,
       primaryNavController.viewControllers.count > 1 {
      true
    } else {
      false
    }
  }

  private func isBackButtonVisible(for column: UISplitViewController.Column) -> Bool {
    let hasParent = (navigationController?.viewControllers.count ?? 0) > 1
    switch column {
    case .primary where displayMode == .oneBesideSecondary:
      if primaryNavHasBackStack {
        return false // The standard backstack will handle
      } else {
        return hasParent
      }
    case .primary:
      return false // primary is either ephemeral or non-visible.
    case .supplementary:
      fatalError("We do not support threeColumn layouts")
    case .secondary:
      return displayMode == .secondaryOnly
        && !secondaryNavHasBackStack // The standard backstack will handle
    case .compact:
      return hasParent || primaryNavHasBackStack
    case .inspector:
      return false
    @unknown default:
      return hasParent || primaryNavHasBackStack
    }
  }

  func buttonState(for column: UISplitViewController.Column) -> SplitButtonState {
    let compactValue = SplitButtonState(
      isBackButtonVisible: isBackButtonVisible(for: .compact),
      isSidebarLeftVisible: false,
      isSidebarTrailingVisible: inspectorVC != nil && supportsInspector
    )

    guard !splitVC.isCollapsed else { return compactValue }

    switch column {
    case .primary:
      return SplitButtonState(
        isBackButtonVisible: isBackButtonVisible(for: .primary),
        isSidebarLeftVisible: true,
        isSidebarTrailingVisible: false
      )
    case .supplementary:
      fatalError("We don't support three column layouts")
    case .secondary:
      return SplitButtonState(
        isBackButtonVisible: isBackButtonVisible(for: .secondary),
        isSidebarLeftVisible: false,
        isSidebarTrailingVisible: inspectorVC != nil && supportsInspector && !isInspectorVisible
      )
    case .compact:
      return compactValue
    case .inspector:
      return SplitButtonState(
        isBackButtonVisible: isBackButtonVisible(for: .primary),
        isSidebarLeftVisible: false,
        isSidebarTrailingVisible: true
      )
    @unknown default:
      return SplitButtonState(
        isBackButtonVisible: isBackButtonVisible(for: .primary),
        isSidebarLeftVisible: false,
        isSidebarTrailingVisible: false
      )
    }
  }
}

import UIKit

extension NavigableSplitViewController {
  var secondaryNavHasBackStack: Bool {
    if let secondaryNavController = secondaryViewController as? UINavigationController,
      secondaryNavController.viewControllers.count > 1
    {
      true
    } else {
      false
    }
  }

  var primaryNavHasBackStack: Bool {
    if let primaryNavController = primaryViewController as? UINavigationController,
      primaryNavController.viewControllers.count > 1
    {
      true
    } else {
      false
    }
  }

  func isBackButtonVisible(for column: UISplitViewController.Column) -> Bool {
    let hasParent = (navigationController?.viewControllers.count ?? 0) > 1
    switch column {
    case .primary:
      if primaryNavHasBackStack {
        return false  // The standard backstack will handle
      } else {
        return hasParent
      }
    case .supplementary:
      fatalError("We do not support threeColumn layouts")
    case .secondary:
      return false
    case .compact:
      return hasParent
    case .inspector:
      return false
    @unknown default:
      return hasParent
    }
  }
}

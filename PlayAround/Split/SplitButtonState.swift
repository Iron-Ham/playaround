import UIKit

struct SplitButtonState: Hashable {
  let isBackButtonVisible: Bool
  let isSidebarLeftVisible: Bool
  let isSidebarTrailingVisible: Bool
}

extension NavigableSplitViewController {
  private var secondaryNavHasBackStack: Bool {
    if let secondaryNavController = secondaryVC as? UINavigationController,
       secondaryNavController.viewControllers.count > 1 {
      true
    } else {
      false
    }
  }

  private var primaryNavHasBackStack: Bool {
    if let primaryNavController = primaryVC as? UINavigationController,
       primaryNavController.viewControllers.count > 1 {
      true
    } else {
      false
    }
  }

  private func isBackButtonVisible(for column: UISplitViewController.Column) -> Bool {
    switch column {
    case .primary where displayMode == .oneBesideSecondary:
      primaryNavHasBackStack
    case .primary:
      false
    case .supplementary:
      fatalError("We do not support threeColumn layouts")
    case .secondary:
      secondaryNavHasBackStack
    case .compact:
      primaryNavHasBackStack
    case .inspector:
      false
    @unknown default:
      primaryNavHasBackStack
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
        isSidebarLeftVisible: displayMode != .secondaryOnly,
        isSidebarTrailingVisible: false
      )
    case .supplementary:
      fatalError("We don't support three column layouts")
    case .secondary:
      return SplitButtonState(
        isBackButtonVisible: isBackButtonVisible(for: .secondary),
        isSidebarLeftVisible: displayMode == .secondaryOnly,
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

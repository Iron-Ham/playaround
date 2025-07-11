import UIKit

public class NavigableSplitViewController: UIViewController {

  var primaryVC: UIViewController? {
    splitVC.viewController(for: .primary)
  }
  var secondaryVC: UIViewController? {
    splitVC.viewController(for: .secondary)
  }
  var inspectorVC: UIViewController? {
    if #available(iOS 26.0, *) {
      splitVC.viewController(for: .inspector)
    } else {
      nil
    }
  }

  let splitVC: UISplitViewController

  var isCompact: Bool {
    splitVC.isCollapsed
  }

  var supportsInspector: Bool {
    if #available(iOS 26.0, *) {
      true
    } else {
      false
    }
  }

  var isInspectorVisible: Bool {
    if #available(iOS 26.0, *) {
      splitVC.isShowing(.inspector)
    } else {
      false
    }
  }

  var displayMode: UISplitViewController.DisplayMode {
    splitVC.displayMode
  }

  public init(
    primary: UIViewController,
    secondary: UIViewController,
    inspector: UIViewController? = nil
  ) {
    self.splitVC = UISplitViewController(style: .doubleColumn)
    splitVC.setViewController(primary, for: .primary)
    splitVC.setViewController(secondary, for: .secondary)

    // Set inspector if available and supported
    if #available(iOS 26.0, *), let inspector = inspector {
      splitVC.setViewController(inspector, for: .inspector)
    }

    splitVC.preferredDisplayMode = .oneBesideSecondary
    splitVC.preferredSplitBehavior = .tile

    // Hide the default sidebar button since we'll provide our own
    // This is because `UISplitViewController` has internal animation timings that don't seem to
    // function correctly when we are nesting within a `UINavigationController` like this.
    //
    // There will be caveats to this approach:
    // For example, when hiding or showing the `primary` column, we elect to do so outside of a
    // `UIView.animate(_: changes:)` block. It's unclear if this is an iPadOS 26 beta bug or if it's
    // a limitation of the nested approach.
    splitVC.presentsWithGesture = false

    super.init(nibName: nil, bundle: nil)
    splitVC.delegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground
    addChild(splitVC)
    view.addSubview(splitVC.view)
    splitVC.didMove(toParent: self)

    splitVC.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      splitVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      splitVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      splitVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      splitVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    title = "Split View"

    setupBackButtonMirroring()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
  }

  private func setupBackButtonMirroring() {
    guard let navController = navigationController,
      navController.viewControllers.count > 1
    else {
      return
    }

    // Apply button state to primary column
    if let primaryNavController = primaryVC as? UINavigationController,
      let topVC = primaryNavController.topViewController
    {
      let buttonState = buttonState(for: .primary)
      updateNavigationButtons(for: topVC, column: .primary, buttonState: buttonState)
    } else if let primaryVC {
      let buttonState = buttonState(for: .primary)
      updateNavigationButtons(for: primaryVC, column: .primary, buttonState: buttonState)
    }

    // Apply button state to secondary column
    if let secondaryNavController = secondaryVC as? UINavigationController,
      let topVC = secondaryNavController.topViewController
    {
      let buttonState = buttonState(for: .secondary)
      updateNavigationButtons(for: topVC, column: .secondary, buttonState: buttonState)
    } else if let secondaryVC {
      let buttonState = buttonState(for: .secondary)
      updateNavigationButtons(for: secondaryVC, column: .secondary, buttonState: buttonState)
    }

    // Apply button state to inspector column if it exists
    if let inspectorVC = inspectorVC, #available(iOS 26.0, *) {
      let buttonState = buttonState(for: .inspector)
      updateNavigationButtons(for: inspectorVC, column: .inspector, buttonState: buttonState)
    }
  }

  private func updateNavigationButtons(
    for viewController: UIViewController,
    column: UISplitViewController.Column,
    buttonState: SplitButtonState
  ) {
    // Create buttons if they don't exist
    ensureNavigationButtonsExist(for: viewController, column: column, buttonState: buttonState)

    // Update button visibility based on state
    updateButtonVisibility(for: viewController, column: column, buttonState: buttonState)
  }

  private func ensureNavigationButtonsExist(
    for viewController: UIViewController,
    column: UISplitViewController.Column,
    buttonState: SplitButtonState
  ) {
    let existingGroups = viewController.navigationItem.leadingItemGroups
    var leadingGroups: [UIBarButtonItemGroup] = []

    // Only add back button if this column should have one
    if buttonState.isBackButtonVisible {
      let hasBackButton = existingGroups.contains { group in
        group.barButtonItems.contains { item in
          item.target === self && item.action == #selector(backButtonTapped)
        }
      }

      if !hasBackButton {
        let backButton = UIBarButtonItem(
          image: UIImage(systemName: "chevron.left"),
          style: .plain,
          target: self,
          action: #selector(backButtonTapped)
        )
        let backButtonGroup = UIBarButtonItemGroup(
          barButtonItems: [backButton],
          representativeItem: nil
        )
        leadingGroups.append(backButtonGroup)
      }
    }

    // Only add sidebar button if this column should have one
    if buttonState.isSidebarLeftVisible {
      let hasSidebarButton = existingGroups.contains { group in
        group.barButtonItems.contains { item in
          item.target === self && item.action == #selector(sidebarButtonTapped)
        }
      }

      if !hasSidebarButton {
        let sidebarButton = UIBarButtonItem(
          image: UIImage(systemName: "sidebar.left"),
          style: .plain,
          target: self,
          action: #selector(sidebarButtonTapped)
        )
        let sidebarButtonGroup = UIBarButtonItemGroup(
          barButtonItems: [sidebarButton],
          representativeItem: nil
        )
        leadingGroups.append(sidebarButtonGroup)
      }
    }

    if !leadingGroups.isEmpty {
      viewController.navigationItem.leadingItemGroups = leadingGroups + existingGroups
    }

    // Only add inspector button if this column should have one
    if shouldShowInspectorButton(for: column, buttonState: buttonState),
      let iconName = inspectorButtonIcon(for: column)
    {
      let hasInspectorButton =
        viewController.navigationItem.pinnedTrailingGroup?.barButtonItems.contains { item in
          item.target === self && item.action == #selector(inspectorButtonTapped)
        } ?? false

      if !hasInspectorButton {
        let inspectorButton = UIBarButtonItem(
          image: UIImage(systemName: iconName),
          style: .plain,
          target: self,
          action: #selector(inspectorButtonTapped)
        )

        let inspectorButtonGroup = UIBarButtonItemGroup(
          barButtonItems: [inspectorButton],
          representativeItem: nil
        )

        viewController.navigationItem.pinnedTrailingGroup = inspectorButtonGroup
      } else {
        // Update existing button icon if it exists
        if let pinnedTrailingGroup = viewController.navigationItem.pinnedTrailingGroup {
          for item in pinnedTrailingGroup.barButtonItems {
            if item.target === self && item.action == #selector(inspectorButtonTapped) {
              item.image = UIImage(systemName: iconName)
            }
          }
        }
      }
    }
  }

  private func updateButtonVisibility(
    for viewController: UIViewController,
    column: UISplitViewController.Column,
    buttonState: SplitButtonState
  ) {
    // Update leading button visibility
    for group in viewController.navigationItem.leadingItemGroups {
      for item in group.barButtonItems {
        if item.target === self && item.action == #selector(backButtonTapped) {
          item.isHidden = !buttonState.isBackButtonVisible
        } else if item.target === self && item.action == #selector(sidebarButtonTapped) {
          item.isHidden = !buttonState.isSidebarLeftVisible
        }
      }
    }

    // Update trailing button visibility and icon
    if let pinnedTrailingGroup = viewController.navigationItem.pinnedTrailingGroup {
      for item in pinnedTrailingGroup.barButtonItems {
        if item.target === self && item.action == #selector(inspectorButtonTapped) {
          let shouldShow = shouldShowInspectorButton(for: column, buttonState: buttonState)
          item.isHidden = !shouldShow

          // Update icon if button is visible
          if shouldShow, let iconName = inspectorButtonIcon(for: column) {
            item.image = UIImage(systemName: iconName)
          }
        }
      }
    }
  }

  private func inspectorButtonIcon(for column: UISplitViewController.Column) -> String? {
    switch column {
    case .secondary:
      // In compact layouts, secondary shows info button
      return isCompact ? "info.circle" : "sidebar.trailing"
    case .inspector:
      // Inspector column in compact layouts should be hidden (return nil)
      return isCompact ? nil : "sidebar.trailing"
    default:
      return "sidebar.trailing"
    }
  }

  private func shouldShowInspectorButton(
    for column: UISplitViewController.Column, buttonState: SplitButtonState
  ) -> Bool {
    // Inspector column in compact layouts should be hidden
    if #available(iOS 26.0, *), column == .inspector && isCompact {
      return false
    }
    return buttonState.isSidebarTrailingVisible
  }

  @objc private func backButtonTapped() {
    if splitVC.displayMode == .secondaryOnly && !secondaryNavHasBackStack {
      splitVC.preferredDisplayMode = .oneBesideSecondary
    } else {
      navigationController?.popViewController(animated: true)
    }
  }

  @objc private func sidebarButtonTapped() {
    if splitVC.displayMode == .secondaryOnly {
      splitVC.preferredDisplayMode = .oneBesideSecondary
    } else {
      splitVC.preferredDisplayMode = .secondaryOnly
    }
  }

  @objc private func inspectorButtonTapped() {
    if #available(iOS 26.0, *) {
      // Toggle inspector column visibility
      if splitVC.isShowing(.inspector) {
        splitVC.hide(.inspector)
      } else {
        splitVC.show(.inspector)
      }

      DispatchQueue.main.async {
        if let secondaryNavController = self.secondaryVC as? UINavigationController,
          let topVC = secondaryNavController.topViewController
        {
          let buttonState = self.buttonState(for: .secondary)
          self.updateNavigationButtons(for: topVC, column: .secondary, buttonState: buttonState)
        } else if let secondaryVC = self.secondaryVC {
          let buttonState = self.buttonState(for: .secondary)
          self.updateNavigationButtons(
            for: secondaryVC, column: .secondary, buttonState: buttonState)
        }

        // Update inspector column buttons if it exists
        if let inspectorVC = self.inspectorVC {
          let buttonState = self.buttonState(for: .inspector)
          self.updateNavigationButtons(
            for: inspectorVC, column: .inspector, buttonState: buttonState)
        }
      }
    }
  }
}

extension NavigableSplitViewController: UISplitViewControllerDelegate {
  public func splitViewController(
    _ svc: UISplitViewController,
    topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
  ) -> UISplitViewController.Column {
    if isCompact {
      UISplitViewController.Column.primary
    } else {
      UISplitViewController.Column.secondary
    }
  }

  public func splitViewController(
    _ svc: UISplitViewController,
    willChangeTo displayMode: UISplitViewController.DisplayMode
  ) {
    // Delay the back button update to avoid interfering with system sidebar button transitions
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.setupBackButtonMirroring()
    }
  }

  public func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
    // Update back button after collapse transition completes
    DispatchQueue.main.async {
      self.setupBackButtonMirroring()
    }
  }

  public func splitViewControllerDidExpand(_ svc: UISplitViewController) {
    // Update back button after expand transition completes
    DispatchQueue.main.async {
      self.setupBackButtonMirroring()
    }
  }

  public func splitViewController(
    _ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?
  ) -> Bool {
    if splitViewController.isCollapsed {
      // When collapsed, replace the top view controller if it's not the master
      guard
        let primaryNavController = splitViewController.viewControllers.first
          as? UINavigationController
      else {
        return false
      }

      // Replace the top view controller (which should be the current detail)
      if primaryNavController.viewControllers.count > 1 {
        primaryNavController.popViewController(animated: false)
      }
      primaryNavController.pushViewController(vc, animated: true)

      // Update navigation buttons after detail change
      DispatchQueue.main.async {
        self.setupBackButtonMirroring()
      }

      return true
    } else {
      // When not collapsed, replace the secondary view controller
      let detailNavController = UINavigationController(rootViewController: vc)
      splitViewController.setViewController(detailNavController, for: .secondary)

      // Update navigation buttons after detail change
      DispatchQueue.main.async {
        self.setupBackButtonMirroring()
      }

      return true
    }
  }
}

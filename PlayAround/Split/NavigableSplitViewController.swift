import UIKit

public class NavigableSplitViewController: UIViewController {

  let primaryVC: UIViewController
  let secondaryVC: UIViewController
  let inspectorVC: UIViewController?

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
    self.primaryVC = primary
    self.secondaryVC = secondary
    self.inspectorVC = inspector
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

    removeBackButtons()

    // Apply button state to primary column
    if let primaryNavController = primaryVC as? UINavigationController,
      let topVC = primaryNavController.topViewController
    {
      let buttonState = buttonState(for: .primary)
      addNavigationButtons(to: topVC, buttonState: buttonState)
    } else {
      let buttonState = buttonState(for: .primary)
      addNavigationButtons(to: primaryVC, buttonState: buttonState)
    }

    // Apply button state to secondary column
    if let secondaryNavController = secondaryVC as? UINavigationController,
      let topVC = secondaryNavController.topViewController
    {
      let buttonState = buttonState(for: .secondary)
      addNavigationButtons(to: topVC, buttonState: buttonState)
    } else {
      let buttonState = buttonState(for: .secondary)
      addNavigationButtons(to: secondaryVC, buttonState: buttonState)
    }

    // Apply button state to inspector column if it exists
    if let inspectorVC = inspectorVC, #available(iOS 26.0, *) {
      let buttonState = buttonState(for: .inspector)
      addNavigationButtons(to: inspectorVC, buttonState: buttonState)
    }
  }

  private func addNavigationButtons(
    to viewController: UIViewController, buttonState: SplitButtonState
  ) {
    var leadingGroups: [UIBarButtonItemGroup] = []

    // Add back button in its own group
    if buttonState.isBackButtonVisible {
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

    // Add sidebar toggle button in its own group
    if buttonState.isSidebarLeftVisible {
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

    // Add inspector toggle button as a pinned trailing item
    if buttonState.isSidebarTrailingVisible {
      let inspectorButton = UIBarButtonItem(
        image: UIImage(systemName: "sidebar.trailing"),
        style: .plain,
        target: self,
        action: #selector(inspectorButtonTapped)
      )

      // Create a pinned group so it always stays visible
      let inspectorButtonGroup = UIBarButtonItemGroup(
        barButtonItems: [inspectorButton],
        representativeItem: nil
      )

      viewController.navigationItem.pinnedTrailingGroup = inspectorButtonGroup
    }

    if !leadingGroups.isEmpty {
      // Get existing groups, being careful not to interfere with system groups
      let existingGroups = viewController.navigationItem.leadingItemGroups

      // Check if we already have our buttons to avoid duplicates
      let hasOurButtons = existingGroups.contains { group in
        group.barButtonItems.contains { item in
          (item.target === self && item.action == #selector(backButtonTapped))
            || (item.target === self && item.action == #selector(sidebarButtonTapped))
        }
      }

      if !hasOurButtons {
        viewController.navigationItem.leadingItemGroups = leadingGroups + existingGroups
      }
    }
  }

  private func removeBackButtons() {
    if let primaryNavController = primaryVC as? UINavigationController,
      let topVC = primaryNavController.topViewController
    {
      removeCustomButtons(from: topVC)
    } else {
      removeCustomButtons(from: primaryVC)
    }

    if let secondaryNavController = secondaryVC as? UINavigationController,
      let topVC = secondaryNavController.topViewController
    {
      removeCustomButtons(from: topVC)
    } else {
      removeCustomButtons(from: secondaryVC)
    }
  }

  private func removeCustomButtons(from viewController: UIViewController) {
    // Remove from leading groups
    let leadingGroups = viewController.navigationItem.leadingItemGroups

    let filteredLeadingGroups = leadingGroups.filter { group in
      !group.barButtonItems.contains { item in
        (item.target === self && item.action == #selector(backButtonTapped))
          || (item.target === self && item.action == #selector(sidebarButtonTapped))
      }
    }

    viewController.navigationItem.leadingItemGroups =
      filteredLeadingGroups.isEmpty ? [] : filteredLeadingGroups

    // For trailing groups, we need to be more careful to preserve the inspector button
    // Only remove inspector buttons if we're explicitly asked to do so
    if let pinnedTrailingGroup = viewController.navigationItem.pinnedTrailingGroup,
       pinnedTrailingGroup.barButtonItems.contains(where: { $0.target === self && $0.action == #selector(inspectorButtonTapped) }) {
      let filteredGroup = pinnedTrailingGroup.barButtonItems.filter { item in
        item.action != #selector(inspectorButtonTapped)
      }
      viewController.navigationItem.pinnedTrailingGroup = UIBarButtonItemGroup(barButtonItems: filteredGroup, representativeItem: nil)
    }
  }

  @objc private func backButtonTapped() {
    navigationController?.popViewController(animated: true)
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
          self.removeCustomButtons(from: topVC)
          let buttonState = self.buttonState(for: .secondary)
          self.addNavigationButtons(to: topVC, buttonState: buttonState)
        } else {
          self.removeCustomButtons(from: self.secondaryVC)
          let buttonState = self.buttonState(for: .secondary)
          self.addNavigationButtons(to: self.secondaryVC, buttonState: buttonState)
        }

        // Update inspector column buttons if it exists
        if let inspectorVC = self.inspectorVC {
          self.removeCustomButtons(from: inspectorVC)
          let buttonState = self.buttonState(for: .inspector)
          self.addNavigationButtons(to: inspectorVC, buttonState: buttonState)
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

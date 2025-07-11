import UIKit

public class NavigableSplitViewController: UIViewController {

  private let primaryVC: UIViewController
  private let secondaryVC: UIViewController

  let splitVC: UISplitViewController

  private var isCompact: Bool {
    UIDevice.current.userInterfaceIdiom == .phone
      || traitCollection.horizontalSizeClass == .compact
  }

  public init(
    primary: UIViewController,
    secondary: UIViewController
  ) {
    self.primaryVC = primary
    self.secondaryVC = secondary
    self.splitVC = UISplitViewController(style: .doubleColumn)
    splitVC.setViewController(primary, for: .primary)
    splitVC.setViewController(secondary, for: .secondary)
    splitVC.preferredDisplayMode = .oneBesideSecondary
    splitVC.preferredSplitBehavior = .tile

    // Hide the default sidebar button since we'll provide our own
    splitVC.presentsWithGesture = false

    super.init(nibName: nil, bundle: nil)
    splitVC.delegate = self
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

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

    let displayMode = splitVC.displayMode
    let shouldShowSidebarButton = !isCompact  // Only show sidebar button in regular layouts

    if displayMode == .secondaryOnly {
      if let secondaryNavController = secondaryVC as? UINavigationController,
        let topVC = secondaryNavController.topViewController
      {
        addNavigationButtons(
          to: topVC, includeBackButton: true, includeSidebarButton: shouldShowSidebarButton)
      } else {
        addNavigationButtons(
          to: secondaryVC, includeBackButton: true, includeSidebarButton: shouldShowSidebarButton)
      }
    } else {
      // Primary column is visible, add back button to primary and sidebar button to secondary if visible
      if let primaryNavController = primaryVC as? UINavigationController,
        let topVC = primaryNavController.topViewController
      {
        addNavigationButtons(to: topVC, includeBackButton: true, includeSidebarButton: false)
      } else {
        addNavigationButtons(to: primaryVC, includeBackButton: true, includeSidebarButton: false)
      }

      // Add sidebar button to secondary if it's visible and we're not in compact mode
      if displayMode == .oneBesideSecondary && shouldShowSidebarButton {
        if let secondaryNavController = secondaryVC as? UINavigationController,
          let topVC = secondaryNavController.topViewController
        {
          addNavigationButtons(to: topVC, includeBackButton: false, includeSidebarButton: true)
        } else {
          addNavigationButtons(
            to: secondaryVC, includeBackButton: false, includeSidebarButton: true)
        }
      }
    }
  }

  private func addNavigationButtons(
    to viewController: UIViewController, includeBackButton: Bool, includeSidebarButton: Bool
  ) {
    var groups: [UIBarButtonItemGroup] = []

    // Add back button in its own group
    if includeBackButton {
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
      groups.append(backButtonGroup)
    }

    // Add sidebar toggle button in its own group
    if includeSidebarButton {
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
      groups.append(sidebarButtonGroup)
    }

    if !groups.isEmpty {
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
        viewController.navigationItem.leadingItemGroups = groups + existingGroups
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
    let leadingGroups = viewController.navigationItem.leadingItemGroups

    let filteredGroups = leadingGroups.filter { group in
      !group.barButtonItems.contains { item in
        (item.target === self && item.action == #selector(backButtonTapped))
          || (item.target === self && item.action == #selector(sidebarButtonTapped))
      }
    }

    viewController.navigationItem.leadingItemGroups = filteredGroups.isEmpty ? [] : filteredGroups
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

      return true
    } else {
      // When not collapsed, replace the secondary view controller
      let detailNavController = UINavigationController(rootViewController: vc)
      splitViewController.setViewController(detailNavController, for: .secondary)

      return true
    }
  }
}

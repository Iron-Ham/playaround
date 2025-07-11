import UIKit

public class NavigableSplitViewController: UIViewController {

  var primaryViewController: UIViewController? {
    splitVC.viewController(for: .primary)
  }
  var secondaryViewController: UIViewController? {
    splitVC.viewController(for: .secondary)
  }

  @available(iOS 26.0, *)
  var inspectorViewController: UIViewController? {
    splitVC.viewController(for: .inspector)
  }

  let splitVC: UISplitViewController

  var isCompact: Bool {
    splitVC.isCollapsed
  }

  var displayMode: UISplitViewController.DisplayMode {
    splitVC.displayMode
  }

  public init(
    primary: UIViewController,
    secondary: UIViewController
  ) {
    self.splitVC = UISplitViewController(style: .doubleColumn)
    splitVC.setViewController(primary, for: .primary)
    splitVC.setViewController(secondary, for: .secondary)

    splitVC.preferredDisplayMode = .oneBesideSecondary
    splitVC.preferredSplitBehavior = .tile

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
      splitVC.view.topAnchor.constraint(equalTo: view.topAnchor),
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
    if let primaryViewController {
      addNavigationButtons(to: primaryViewController, includeBackButton: isBackButtonVisible(for: .primary))
    }
  }

  private func addNavigationButtons(to viewController: UIViewController, includeBackButton: Bool) {
    var leadingGroups: [UIBarButtonItemGroup] = []
    let existingGroups = viewController.navigationItem.leadingItemGroups

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
      leadingGroups.append(backButtonGroup)
    }

    viewController.navigationItem.leadingItemGroups = leadingGroups + existingGroups
  }

  private func removeBackButtons() {
    if let primaryNavController = primaryViewController as? UINavigationController,
      let topVC = primaryNavController.topViewController
    {
      removeCustomButtons(from: topVC)
    } else if let primaryViewController {
      removeCustomButtons(from: primaryViewController)
    }

    if let secondaryNavController = secondaryViewController as? UINavigationController,
      let topVC = secondaryNavController.topViewController
    {
      removeCustomButtons(from: topVC)
    } else if let secondaryViewController {
      removeCustomButtons(from: secondaryViewController)
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
    let trailingGroups = viewController.navigationItem.trailingItemGroups

    let filteredTrailingGroups = trailingGroups.filter { group in
      !group.barButtonItems.contains { item in
        item.target === self && item.action == #selector(inspectorButtonTapped)
      }
    }

    // Only update trailing groups if we actually found inspector buttons to remove
    if filteredTrailingGroups.count != trailingGroups.count {
      viewController.navigationItem.trailingItemGroups =
        filteredTrailingGroups.isEmpty ? [] : filteredTrailingGroups
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

      return true
    }
  }
}

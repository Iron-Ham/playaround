import UIKit

public class NavigableSplitViewController: UIViewController {

  private let primaryVC: UIViewController
  private let secondaryVC: UIViewController

  let splitVC: UISplitViewController

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

    if displayMode == .secondaryOnly {
      if let secondaryNavController = secondaryVC as? UINavigationController,
        let topVC = secondaryNavController.topViewController
      {
        addBackButton(to: topVC)
      } else {
        addBackButton(to: secondaryVC)
      }
    } else {
      // Primary column is visible (either alone or with secondary), add back button to primary
      if let primaryNavController = primaryVC as? UINavigationController,
        let topVC = primaryNavController.topViewController
      {
        addBackButton(to: topVC)
      } else {
        addBackButton(to: primaryVC)
      }
    }
  }

  private func addBackButton(to viewController: UIViewController) {
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

    let existingGroups = viewController.navigationItem.leadingItemGroups
    viewController.navigationItem.leadingItemGroups = [backButtonGroup] + existingGroups
  }

  private func removeBackButtons() {
    if let primaryNavController = primaryVC as? UINavigationController,
      let topVC = primaryNavController.topViewController
    {
      removeBackButton(from: topVC)
    } else {
      removeBackButton(from: primaryVC)
    }

    if let secondaryNavController = secondaryVC as? UINavigationController,
      let topVC = secondaryNavController.topViewController
    {
      removeBackButton(from: topVC)
    } else {
      removeBackButton(from: secondaryVC)
    }
  }

  private func removeBackButton(from viewController: UIViewController) {
    let leadingGroups = viewController.navigationItem.leadingItemGroups

    let filteredGroups = leadingGroups.filter { group in
      !group.barButtonItems.contains { item in
        item.target === self && item.action == #selector(backButtonTapped)
      }
    }

    viewController.navigationItem.leadingItemGroups = filteredGroups.isEmpty ? [] : filteredGroups
  }

  @objc private func backButtonTapped() {
    navigationController?.popViewController(animated: true)
  }
}

extension NavigableSplitViewController: UISplitViewControllerDelegate {
  public func splitViewController(
    _ svc: UISplitViewController,
    topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
  ) -> UISplitViewController.Column {
    if UIDevice.current.userInterfaceIdiom == .phone
      || traitCollection.horizontalSizeClass == .compact
    {
      return .primary
    }

    return .secondary
  }

  public func splitViewController(
    _ svc: UISplitViewController,
    willChangeTo displayMode: UISplitViewController.DisplayMode
  ) {
    DispatchQueue.main.async {
      self.setupBackButtonMirroring()
    }
  }
}

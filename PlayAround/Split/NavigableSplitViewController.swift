import UIKit

public class NavigableSplitViewController: UIViewController {

  public let splitView: UISplitViewController

  public var primaryViewController: UIViewController? {
    get { splitView.viewController(for: .primary) }
    set { splitView.setViewController(newValue, for: .primary) }
  }

  public var secondaryViewController: UIViewController? {
    get { splitView.viewController(for: .secondary) }
    set { splitView.setViewController(newValue, for: .secondary) }
  }

  public var shouldCollapseInCompact: Bool = true

  public var collapseHandler: ((UISplitViewController, UIViewController, UIViewController) -> Bool)?

  public var separateHandler: ((UISplitViewController, UIViewController) -> UIViewController?)?

  public init(splitViewController: UISplitViewController) {
    self.splitView = splitViewController
    super.init(nibName: nil, bundle: nil)

    self.splitView.delegate = self

    self.splitView.preferredDisplayMode = .oneBesideSecondary
    self.splitView.preferredSplitBehavior = .displace
  }

  public convenience init(
    primary: UIViewController,
    secondary: UIViewController
  ) {
    let splitVC = UISplitViewController(style: .doubleColumn)
    
    // Wrap in navigation controllers for listDetail behavior
    let primaryNav = UINavigationController(rootViewController: primary)
    let secondaryNav = UINavigationController(rootViewController: secondary)
    
    splitVC.setViewController(primaryNav, for: .primary)
    splitVC.setViewController(secondaryNav, for: .secondary)

    self.init(splitViewController: splitVC)
    
    // Set up default listDetail behavior
    self.shouldCollapseInCompact = true
    self.collapseHandler = { _, _, _ in
      true // Always collapse in compact mode
    }
  }

  public convenience init(
    configuration: (UISplitViewController) -> Void
  ) {
    let splitVC = UISplitViewController(style: .doubleColumn)
    configuration(splitVC)
    self.init(splitViewController: splitVC)
    
    // Set up default listDetail behavior
    self.shouldCollapseInCompact = true
    self.collapseHandler = { _, _, _ in
      true // Always collapse in compact mode
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  public override func viewDidLoad() {
    super.viewDidLoad()

    addChild(splitView)
    view.addSubview(splitView.view)
    splitView.didMove(toParent: self)

    splitView.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      splitView.view.topAnchor.constraint(equalTo: view.topAnchor),
      splitView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      splitView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      splitView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    if let primaryTitle = primaryViewController?.title {
      title = primaryTitle
    }
    
    setupBackButton()
  }
  
  private func setupBackButton() {
    updateBackButtonForCurrentDisplayMode()
  }
  
  private func updateBackButtonForCurrentDisplayMode() {
    // Only show back button if we're in a navigation stack
    guard let navigationController = navigationController,
          navigationController.viewControllers.count > 1 else {
      return
    }
    
    // Clear any existing back buttons
    clearBackButtons()
    
    let displayMode = splitView.displayMode
    
    if displayMode == .secondaryOnly {
      // In secondary-only mode, add back button to secondary
      addBackButtonToSecondary()
    } else {
      // In other modes (oneBesideSecondary, oneOverSecondary), add back button to primary
      addBackButtonToPrimary()
    }
  }
  
  private func clearBackButtons() {
    // Clear primary back button
    if let primaryNav = primaryViewController as? UINavigationController,
       let primaryRoot = primaryNav.viewControllers.first {
      primaryRoot.navigationItem.leftBarButtonItem = nil
    }
    
    // Clear secondary back button
    if let secondaryNav = secondaryViewController as? UINavigationController,
       let secondaryRoot = secondaryNav.viewControllers.first {
      secondaryRoot.navigationItem.leftBarButtonItem = nil
    }
  }
  
  private func addBackButtonToPrimary() {
    guard let primaryNav = primaryViewController as? UINavigationController,
          let primaryRoot = primaryNav.viewControllers.first else {
      return
    }
    
    let backButton = UIBarButtonItem(
      image: UIImage(systemName: "chevron.left"),
      style: .plain,
      target: self,
      action: #selector(backButtonTapped)
    )
    
    primaryRoot.navigationItem.leftBarButtonItem = backButton
  }
  
  private func addBackButtonToSecondary() {
    guard let secondaryNav = secondaryViewController as? UINavigationController,
          let secondaryRoot = secondaryNav.viewControllers.first else {
      return
    }
    
    let backButton = UIBarButtonItem(
      image: UIImage(systemName: "chevron.left"),
      style: .plain,
      target: self,
      action: #selector(backButtonTapped)
    )
    
    secondaryRoot.navigationItem.leftBarButtonItem = backButton
  }
  
  @objc private func backButtonTapped() {
    navigationController?.popViewController(animated: true)
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Hide the top-level navigation bar since the split view has its own navigation
    navigationController?.setNavigationBarHidden(true, animated: animated)
    
    // Update back button for current display mode
    updateBackButtonForCurrentDisplayMode()
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Show the top-level navigation bar when leaving the split view
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  @objc private func toggleDisplayMode() {
    let currentMode = splitView.displayMode
    let newMode: UISplitViewController.DisplayMode

    switch currentMode {
    case .oneBesideSecondary, .oneOverSecondary:
      newMode = .secondaryOnly
    case .secondaryOnly:
      newMode = .oneBesideSecondary
    default:
      newMode = .oneBesideSecondary
    }

    splitView.preferredDisplayMode = newMode
    
    // Update back button placement after display mode change
    DispatchQueue.main.async {
      self.updateBackButtonForCurrentDisplayMode()
    }
  }

  public func pushSecondary(_ viewController: UIViewController, animated: Bool = true) {
    if let navController = secondaryViewController as? UINavigationController {
      navController.pushViewController(viewController, animated: animated)
    } else {
      let navController = UINavigationController(rootViewController: viewController)
      secondaryViewController = navController
    }
  }

  public func setSecondary(_ viewController: UIViewController, animated: Bool = true) {
    if animated {
      UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve) {
        self.secondaryViewController = viewController
      }
    } else {
      secondaryViewController = viewController
    }
  }

  /// Show a view controller in the secondary pane (used when navigating from primary)
  public func showInSecondary(_ viewController: UIViewController, animated: Bool = true) {
    // Wrap in navigation controller if needed
    let navController: UINavigationController
    if let existingNav = viewController as? UINavigationController {
      navController = existingNav
    } else {
      navController = UINavigationController(rootViewController: viewController)
    }
    
    setSecondary(navController, animated: animated)
  }

  /// Push a view controller onto the navigation stack (used when navigating from secondary)
  public func pushViewController(_ viewController: UIViewController, animated: Bool = true) {
    navigationController?.pushViewController(viewController, animated: animated)
  }

  public func setPrimaryVisible(_ visible: Bool, animated: Bool = true) {
    let displayMode: UISplitViewController.DisplayMode =
      visible ? .oneBesideSecondary : .secondaryOnly

    if animated {
      UIView.animate(withDuration: 0.3) {
        self.splitView.preferredDisplayMode = displayMode
      } completion: { _ in
        self.updateBackButtonForCurrentDisplayMode()
      }
    } else {
      splitView.preferredDisplayMode = displayMode
      updateBackButtonForCurrentDisplayMode()
    }
  }

  public var displayMode: UISplitViewController.DisplayMode {
    splitView.displayMode
  }
}

extension NavigableSplitViewController: UISplitViewControllerDelegate {

  public func splitViewController(
    _ splitViewController: UISplitViewController,
    collapseSecondary secondaryViewController: UIViewController,
    onto primaryViewController: UIViewController
  ) -> Bool {
    if let handler = collapseHandler {
      return handler(splitViewController, primaryViewController, secondaryViewController)
    }

    return shouldCollapseInCompact
  }

  public func splitViewController(
    _ splitViewController: UISplitViewController,
    separateSecondaryFrom primaryViewController: UIViewController
  ) -> UIViewController? {
    if let handler = separateHandler {
      return handler(splitViewController, primaryViewController)
    }

    return nil
  }
}

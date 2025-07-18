import UIKit

public class NavigableSplitViewController: UIViewController {

  public var primaryViewController: UIViewController? {
    splitVC.viewController(for: .primary)
  }

  public var secondaryViewController: UIViewController? {
    splitVC.viewController(for: .secondary)
  }

  @available(iOS 26.0, *)
  public var inspectorViewController: UIViewController? {
    splitVC.viewController(for: .inspector)
  }

  private let splitVC: CustomUISplitViewController

  var isCompact: Bool {
    splitVC.isCollapsed
  }

  public var displayMode: UISplitViewController.DisplayMode {
    splitVC.displayMode
  }

  private var deferredSecondaryViewController: UIViewController?

  public init(
    primary: UIViewController,
    secondary: UIViewController?
  ) {
    self.splitVC = CustomUISplitViewController(style: .doubleColumn)
    splitVC.preferredDisplayMode = .oneBesideSecondary
    splitVC.preferredSplitBehavior = .tile

    super.init(nibName: nil, bundle: nil)

    splitVC.setViewController(primary, for: .primary)
    // Possible iOS 26 Beta Bug:
    // This must be deferred until after `viewDidAppear`, or we will end up in an infinite
    // logging loop, which consumes all system resources. This only applies in compact mode.
    //
    // On older systems, this works as intended.
    // https://developer.apple.com/forums/thread/792740#792740021
    if #available(iOS 26.0, *), traitCollection.horizontalSizeClass == .compact {
      self.deferredSecondaryViewController = secondary
    } else {
      splitVC.setViewController(secondary, for: .secondary)
    }
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

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let deferredSecondaryViewController {
      DispatchQueue.main.async {
        self.splitVC.showDetailViewController(deferredSecondaryViewController, sender: nil)
      }
    }
  }

  private func setupBackButtonMirroring() {
    guard let navController = navigationController,
      navController.viewControllers.count > 1
    else {
      return
    }

    if let primaryViewController {
      addNavigationButtons(
        to: primaryViewController, includeBackButton: isBackButtonVisible(for: .primary))
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

  @objc private func backButtonTapped() {
    navigationController?.popViewController(animated: true)
  }
}

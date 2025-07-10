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
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
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

    // If transitioning from regular to compact (like iPad rotation), show secondary
    return .secondary
  }
}

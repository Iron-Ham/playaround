import SwiftUI
import UIKit

/// Example view controller showing how to use NavigableSplitViewController
class SplitViewDemoViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Split View Demo"
    view.backgroundColor = .systemBackground

    setupUI()
  }

  private func setupUI() {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 20
    stackView.alignment = .center
    stackView.translatesAutoresizingMaskIntoConstraints = false

    // Title label
    let titleLabel = UILabel()
    titleLabel.text = "NavigableSplitViewController Demo"
    titleLabel.font = .preferredFont(forTextStyle: .title1)
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0

    // Description label
    let descriptionLabel = UILabel()
    descriptionLabel.text =
      "Tap the buttons below to push different split view configurations onto the navigation stack"
    descriptionLabel.font = .preferredFont(forTextStyle: .body)
    descriptionLabel.textAlignment = .center
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textColor = .secondaryLabel

    // Basic split view button
    let basicButton = UIButton(type: .system)
    basicButton.setTitle("Basic Split View", for: .normal)
    basicButton.addTarget(self, action: #selector(showBasicSplitView), for: .touchUpInside)
    basicButton.backgroundColor = .systemBlue
    basicButton.setTitleColor(.white, for: .normal)
    basicButton.layer.cornerRadius = 8
    basicButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)

    // List-detail split view button
    let listDetailButton = UIButton(type: .system)
    listDetailButton.setTitle("Numbers List-Detail", for: .normal)
    listDetailButton.addTarget(
      self,
      action: #selector(showListDetailSplitView),
      for: .touchUpInside
    )
    listDetailButton.backgroundColor = .systemGreen
    listDetailButton.setTitleColor(.white, for: .normal)
    listDetailButton.layer.cornerRadius = 8
    listDetailButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)

    // Add to stack view
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(descriptionLabel)
    stackView.addArrangedSubview(basicButton)
    stackView.addArrangedSubview(listDetailButton)

    view.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
      stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
    ])
  }

  @objc private func showBasicSplitView() {
    let primaryVC = createSampleViewController(title: "Primary", color: .systemBlue)
    let secondaryVC = createSampleViewController(title: "Secondary", color: .systemGreen)

    let splitVC = NavigableSplitViewController(
      primary: primaryVC,
      secondary: secondaryVC
    )
    splitVC.title = "Basic Split View"

    navigationController?.pushViewController(splitVC, animated: true)
  }

  @objc private func showListDetailSplitView() {
    let listVC = SampleListViewController()
    let detailVC = SampleDetailViewController()
    detailVC.selectedNumber = 1 // Default to showing details for number 1

    let splitVC = NavigableSplitViewController(
      primary: SampleListViewController(),
      secondary: SampleDetailViewController()
    )
    splitVC.title = "Numbers Explorer"

    navigationController?.pushViewController(splitVC, animated: true)
  }

  private func createSampleViewController(title: String, color: UIColor) -> UIViewController {
    let vc = UIViewController()
    vc.title = title
    vc.view.backgroundColor = color.withAlphaComponent(0.1)

    let label = UILabel()
    label.text = title
    label.font = .preferredFont(forTextStyle: .title1)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false

    vc.view.addSubview(label)

    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
    ])

    return vc
  }
}

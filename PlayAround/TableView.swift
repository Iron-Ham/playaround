import UIKit
import SwiftUI

final class RootTabViewController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTabBarController()
    self.mode = .tabSidebar
  }

  private func setupTabBarController() {
    let homeVC = UINavigationController(rootViewController: SimpleDemoViewController(tabTitle: "Home"))
    let splitDemoVC = UINavigationController(rootViewController: SplitViewDemoTabViewController())
    let profileVC = UINavigationController(rootViewController: SimpleDemoViewController(tabTitle: "Profile"))

    homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
    splitDemoVC.tabBarItem = UITabBarItem(title: "Split Demo", image: UIImage(systemName: "sidebar.left"), tag: 1)
    profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)

    viewControllers = [homeVC, splitDemoVC, profileVC]

    tabBar.tintColor = .systemBlue
    tabBar.backgroundColor = .systemBackground
  }

}

class TableViewController: UIViewController {

  private let tableView = UITableView()

  private var inspectorHostingController: UIHostingController<InspectorView>?
  private var isInspectorPresented = false

  private let sampleData = [
    "Split View Demo", "Item 1", "Item 2", "Item 3", "Item 4", "Item 5",
    "Item 6", "Item 7", "Item 8", "Item 9", "Item 10"
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Table View, UIKit"
    setupTableView()
    setupNavigationBar()
  }

  private func setupTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.cellLayoutMarginsFollowReadableWidth = true
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }

  private func setupNavigationBar() {
    title = "My Table View"

    let inspectorButton = UIBarButtonItem(
      image: UIImage(systemName: "sidebar.trailing"),
      style: .plain,
      target: self,
      action: #selector(toggleInspectorView)
    )

    navigationItem.rightBarButtonItem = inspectorButton
  }

  @objc private func toggleInspectorView() {
    if isInspectorPresented {
      hideInspector()
    } else {
      showInspector()
    }
  }

  private func showInspector() {
    let inspectorView = InspectorView(
      onDismiss: { [weak self] in
        self?.hideInspector()
      }
    )

    inspectorHostingController = UIHostingController(rootView: inspectorView)
    guard let hostingController = inspectorHostingController else { return }

    addChild(hostingController)
    view.addSubview(hostingController.view)
    hostingController.didMove(toParent: self)

    hostingController.view.translatesAutoresizingMaskIntoConstraints = false

    let widthConstraint = hostingController.view.widthAnchor.constraint(equalToConstant: 320)

    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      widthConstraint
    ])

    hostingController.view.transform = CGAffineTransform(translationX: 320, y: 0)

    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
      hostingController.view.transform = .identity
    }

    isInspectorPresented = true

    navigationItem.rightBarButtonItem?.image = UIImage(systemName: "xmark")
  }

  private func hideInspector() {
    guard let hostingController = inspectorHostingController else { return }

    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
      hostingController.view.transform = CGAffineTransform(translationX: 320, y: 0)
    } completion: { _ in
      hostingController.willMove(toParent: nil)
      hostingController.view.removeFromSuperview()
      hostingController.removeFromParent()

      self.inspectorHostingController = nil
    }

    isInspectorPresented = false

    navigationItem.rightBarButtonItem?.image = UIImage(systemName: "sidebar.trailing")
  }
}

extension TableViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sampleData.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = sampleData[indexPath.row]
    cell.accessoryType = .disclosureIndicator
    return cell
  }
}

extension TableViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let selectedItem = sampleData[indexPath.row]
    
    if selectedItem == "Split View Demo" {
      let splitDemoVC = UITableViewController()
      navigationController?.pushViewController(splitDemoVC, animated: true)
    } else {
      // Handle other row selections
      print("Selected: \(selectedItem)")
    }
  }
}

struct InspectorView: View {
  let onDismiss: () -> Void
  @State private var selectedOption = 0
  @State private var isEnabled = true
  @State private var sliderValue: Double = 50

  var body: some View {
    NavigationView {
      VStack(alignment: .leading, spacing: 20) {
        HStack {
          Text("Inspector")
            .font(.title2)
            .fontWeight(.semibold)
        }
        .padding(.horizontal)
        .padding(.top, 10)

        Divider()

        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
            InspectorSection(title: "Properties") {
              VStack(alignment: .leading, spacing: 16) {
                HStack {
                  Text("Enable Feature")
                  Spacer()
                  Toggle("", isOn: $isEnabled)
                }

                VStack(alignment: .leading, spacing: 8) {
                  Text("Value: \(Int(sliderValue))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                  Slider(value: $sliderValue, in: 0...100)
                }

                VStack(alignment: .leading, spacing: 8) {
                  Text("Options")
                    .font(.caption)
                    .foregroundColor(.secondary)

                  Picker("Options", selection: $selectedOption) {
                    Text("Option 1").tag(0)
                    Text("Option 2").tag(1)
                    Text("Option 3").tag(2)
                  }
                  .pickerStyle(SegmentedPickerStyle())
                }
              }
            }

            InspectorSection(title: "Actions") {
              VStack(spacing: 12) {
                Button(action: {
                  print("Action 1 performed")
                }) {
                  HStack {
                    Image(systemName: "star.fill")
                    Text("Favorite")
                    Spacer()
                  }
                  .padding(.vertical, 8)
                  .padding(.horizontal, 12)
                  .background(Color.blue.opacity(0.1))
                  .foregroundColor(.blue)
                  .cornerRadius(8)
                }

                Button(action: {
                  print("Action 2 performed")
                }) {
                  HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                    Spacer()
                  }
                  .padding(.vertical, 8)
                  .padding(.horizontal, 12)
                  .background(Color.green.opacity(0.1))
                  .foregroundColor(.green)
                  .cornerRadius(8)
                }

                Button(action: {
                  print("Action 3 performed")
                }) {
                  HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                    Spacer()
                  }
                  .padding(.vertical, 8)
                  .padding(.horizontal, 12)
                  .background(Color.red.opacity(0.1))
                  .foregroundColor(.red)
                  .cornerRadius(8)
                }
              }
            }

            InspectorSection(title: "Information") {
              VStack(alignment: .leading, spacing: 12) {
                InfoRow(title: "Created", value: "2025-07-09")
                InfoRow(title: "Modified", value: "2025-07-09")
                InfoRow(title: "Size", value: "1.2 MB")
                InfoRow(title: "Type", value: "Table View")
              }
            }
          }
          .padding(.horizontal)
        }

        Spacer()
      }
      .background(Color(.systemGroupedBackground))
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct InspectorSection<Content: View>: View {
  let title: String
  let content: Content

  init(title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)
        .foregroundColor(.primary)

      content
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
  }
}

struct InfoRow: View {
  let title: String
  let value: String

  var body: some View {
    HStack {
      Text(title)
        .foregroundColor(.secondary)
      Spacer()
      Text(value)
        .foregroundColor(.primary)
    }
    .font(.system(size: 14))
  }
}

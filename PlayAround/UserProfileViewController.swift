import UIKit

protocol UserProfileViewControllerDelegate: AnyObject {
  func userProfileViewController(
    _ controller: UserProfileViewController, didUpdateProfile profile: UserProfile)
}

final class UserProfileViewController: UIViewController {
  weak var delegate: UserProfileViewControllerDelegate?

  private var userProfile: UserProfile = UserProfile.sampleProfile

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.showsVerticalScrollIndicator = true
    return scrollView
  }()

  private lazy var contentStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 24
    stackView.alignment = .fill
    return stackView
  }()

  // Profile Header Section
  private lazy var profileHeaderView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .secondarySystemBackground
    view.layer.cornerRadius = 16
    return view
  }()

  private lazy var profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 50
    imageView.layer.masksToBounds = true
    imageView.backgroundColor = .systemBlue
    return imageView
  }()

  private lazy var initialsLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 32, weight: .semibold)
    label.textColor = .white
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 28, weight: .bold)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()

  private lazy var emailLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16)
    label.textColor = .systemBlue
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()

  private lazy var editProfileButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Edit Profile", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 8
    button.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
    return button
  }()

  // Information Sections
  private lazy var infoSectionView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .secondarySystemBackground
    view.layer.cornerRadius = 16
    return view
  }()

  private lazy var bioTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "About"
    label.font = .systemFont(ofSize: 20, weight: .semibold)
    label.textColor = .label
    return label
  }()

  private lazy var bioLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16)
    label.textColor = .secondaryLabel
    label.numberOfLines = 0
    label.textAlignment = .justified
    return label
  }()

  private lazy var detailsStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.alignment = .fill
    return stackView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    restorationIdentifier = "UserProfileViewController"
    setupUI()
    updateContent()
  }

  private func setupUI() {
    title = "Profile"
    view.backgroundColor = .systemBackground

    // Add navigation bar button
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "gear"),
      style: .plain,
      target: self,
      action: #selector(settingsTapped)
    )

    view.addSubview(scrollView)
    scrollView.addSubview(contentStackView)

    // Setup profile header
    setupProfileHeader()

    // Setup info section
    setupInfoSection()

    // Add sections to main stack view
    contentStackView.addArrangedSubview(profileHeaderView)
    contentStackView.addArrangedSubview(infoSectionView)

    setupConstraints()
  }

  private func setupProfileHeader() {
    profileHeaderView.addSubview(profileImageView)
    profileImageView.addSubview(initialsLabel)
    profileHeaderView.addSubview(nameLabel)
    profileHeaderView.addSubview(emailLabel)
    profileHeaderView.addSubview(editProfileButton)

    NSLayoutConstraint.activate([
      profileImageView.topAnchor.constraint(equalTo: profileHeaderView.topAnchor, constant: 24),
      profileImageView.centerXAnchor.constraint(equalTo: profileHeaderView.centerXAnchor),
      profileImageView.widthAnchor.constraint(equalToConstant: 100),
      profileImageView.heightAnchor.constraint(equalToConstant: 100),

      initialsLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
      initialsLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),

      nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
      nameLabel.leadingAnchor.constraint(equalTo: profileHeaderView.leadingAnchor, constant: 20),
      nameLabel.trailingAnchor.constraint(equalTo: profileHeaderView.trailingAnchor, constant: -20),

      emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
      emailLabel.leadingAnchor.constraint(equalTo: profileHeaderView.leadingAnchor, constant: 20),
      emailLabel.trailingAnchor.constraint(
        equalTo: profileHeaderView.trailingAnchor, constant: -20),

      editProfileButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
      editProfileButton.centerXAnchor.constraint(equalTo: profileHeaderView.centerXAnchor),
      editProfileButton.widthAnchor.constraint(equalToConstant: 120),
      editProfileButton.heightAnchor.constraint(equalToConstant: 40),
      editProfileButton.bottomAnchor.constraint(
        equalTo: profileHeaderView.bottomAnchor, constant: -24),
    ])
  }

  private func setupInfoSection() {
    let bioSectionStack = UIStackView(arrangedSubviews: [bioTitleLabel, bioLabel])
    bioSectionStack.axis = .vertical
    bioSectionStack.spacing = 12
    bioSectionStack.alignment = .fill

    detailsStackView.addArrangedSubview(bioSectionStack)
    detailsStackView.addArrangedSubview(
      createDetailRow(title: "Member Since", value: formatJoinDate()))
    detailsStackView.addArrangedSubview(
      createDetailRow(title: "Location", value: userProfile.location))
    detailsStackView.addArrangedSubview(
      createDetailRow(title: "Favorite Category", value: userProfile.favoriteCategory.rawValue))

    if let website = userProfile.website {
      detailsStackView.addArrangedSubview(
        createDetailRow(title: "Website", value: website, isLink: true))
    }

    infoSectionView.addSubview(detailsStackView)

    NSLayoutConstraint.activate([
      detailsStackView.topAnchor.constraint(equalTo: infoSectionView.topAnchor, constant: 20),
      detailsStackView.leadingAnchor.constraint(
        equalTo: infoSectionView.leadingAnchor, constant: 20),
      detailsStackView.trailingAnchor.constraint(
        equalTo: infoSectionView.trailingAnchor, constant: -20),
      detailsStackView.bottomAnchor.constraint(
        equalTo: infoSectionView.bottomAnchor, constant: -20),
    ])
  }

  private func createDetailRow(title: String, value: String, isLink: Bool = false) -> UIView {
    let containerView = UIView()

    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
    titleLabel.textColor = .label
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    let valueLabel = UILabel()
    valueLabel.text = value
    valueLabel.font = .systemFont(ofSize: 16)
    valueLabel.textColor = isLink ? .systemBlue : .secondaryLabel
    valueLabel.numberOfLines = 0
    valueLabel.translatesAutoresizingMaskIntoConstraints = false

    if isLink {
      valueLabel.isUserInteractionEnabled = true
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(websiteTapped))
      valueLabel.addGestureRecognizer(tapGesture)
    }

    containerView.addSubview(titleLabel)
    containerView.addSubview(valueLabel)

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
      titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

      valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
      valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
    ])

    return containerView
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
      contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
      contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
      contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
      contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
    ])
  }

  private func updateContent() {
    nameLabel.text = userProfile.fullName
    emailLabel.text = userProfile.email
    bioLabel.text = userProfile.bio
    initialsLabel.text = userProfile.initials

    if let profileImage = userProfile.profileImage {
      profileImageView.image = profileImage
      initialsLabel.isHidden = true
    } else {
      profileImageView.image = nil
      initialsLabel.isHidden = false
    }
  }

  private func formatJoinDate() -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: userProfile.joinDate)
  }

  @objc private func editProfileTapped() {
    let alert = UIAlertController(
      title: "Edit Profile", message: "Profile editing coming soon!", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }

  @objc private func settingsTapped() {
    let alert = UIAlertController(
      title: "Settings", message: "Settings menu coming soon!", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }

  @objc private func websiteTapped() {
    guard let website = userProfile.website, let url = URL(string: website) else { return }
    UIApplication.shared.open(url)
  }

  func configure(with profile: UserProfile) {
    self.userProfile = profile
    if isViewLoaded {
      updateContent()
    }
  }
}

import UIKit

struct UserProfile {
  let id = UUID()
  var firstName: String
  var lastName: String
  var email: String
  var bio: String
  var profileImage: UIImage?
  var joinDate: Date
  var favoriteCategory: ItemType
  var location: String
  var website: String?

  var fullName: String {
    return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
  }

  var initials: String {
    let firstInitial = firstName.first?.uppercased() ?? ""
    let lastInitial = lastName.first?.uppercased() ?? ""
    return "\(firstInitial)\(lastInitial)"
  }

  static let sampleProfile = UserProfile(
    firstName: "Alex",
    lastName: "Johnson",
    email: "alex.johnson@example.com",
    bio:
      "Foodie, color enthusiast, and beverage connoisseur. I love exploring new flavors and discovering the perfect combinations of taste, color, and experience. Always on the hunt for the next great meal or refreshing drink!",
    profileImage: nil,
    joinDate: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
    favoriteCategory: .foods,
    location: "San Francisco, CA",
    website: "https://alexjohnson.blog"
  )
}

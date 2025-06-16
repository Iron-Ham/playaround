import UIKit

struct ColorItem {
  let id = UUID()
  let name: String
  let description: String
  let color: UIColor
  let hexValue: String
  let category: String

  static let sampleColors: [ColorItem] = [
    ColorItem(
      name: "Ocean Blue",
      description:
        "A deep, calming blue reminiscent of the vast ocean depths. This color evokes feelings of tranquility and endless possibilities, like gazing into the horizon where the sea meets the sky.",
      color: UIColor(red: 0.0, green: 0.5, blue: 0.8, alpha: 1.0),
      hexValue: "#0080CC",
      category: "Blue"
    ),
    ColorItem(
      name: "Forest Green",
      description:
        "A rich, natural green that captures the essence of a lush forest canopy. This earthy tone represents growth, harmony with nature, and the refreshing feeling of walking through woodland paths.",
      color: UIColor(red: 0.13, green: 0.55, blue: 0.13, alpha: 1.0),
      hexValue: "#228B22",
      category: "Green"
    ),
    ColorItem(
      name: "Sunset Orange",
      description:
        "A warm, vibrant orange that embodies the magical moments of sunset. This energetic color brings feelings of enthusiasm, creativity, and the cozy warmth of golden hour light.",
      color: UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),
      hexValue: "#FF8000",
      category: "Orange"
    ),
    ColorItem(
      name: "Royal Purple",
      description:
        "An elegant, majestic purple that has been associated with nobility and luxury throughout history. This sophisticated color represents creativity, mystery, and spiritual depth.",
      color: UIColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0),
      hexValue: "#800080",
      category: "Purple"
    ),
    ColorItem(
      name: "Cherry Red",
      description:
        "A bold, passionate red that captures attention and commands respect. This powerful color symbolizes love, energy, and determination, like the vibrant skin of a ripe cherry.",
      color: UIColor(red: 0.87, green: 0.19, blue: 0.39, alpha: 1.0),
      hexValue: "#DE3163",
      category: "Red"
    ),
    ColorItem(
      name: "Golden Yellow",
      description:
        "A bright, cheerful yellow that radiates warmth and positivity. Like sunshine itself, this optimistic color brings joy, enlightenment, and the promise of new beginnings.",
      color: UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0),
      hexValue: "#FFD700",
      category: "Yellow"
    ),
    ColorItem(
      name: "Midnight Black",
      description:
        "A deep, sophisticated black that represents elegance and timeless style. This classic color embodies mystery, power, and the infinite possibilities that lie within the darkness.",
      color: UIColor.black,
      hexValue: "#000000",
      category: "Black"
    ),
    ColorItem(
      name: "Pearl White",
      description:
        "A pure, clean white with subtle luminous undertones like a precious pearl. This pristine color represents purity, new beginnings, and the endless potential of a blank canvas.",
      color: UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0),
      hexValue: "#F2F2F2",
      category: "White"
    ),
  ]
}

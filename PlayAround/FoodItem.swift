import Foundation

struct FoodItem {
  let id = UUID()
  let name: String
  let description: String
  let emoji: String
  let category: String
  let origin: String

  static let sampleFoods: [FoodItem] = [
    FoodItem(
      name: "Pizza",
      description:
        "A delicious Italian dish consisting of a usually round, flattened base of leavened wheat-based dough topped with tomatoes, cheese, and often various other ingredients, which is then baked at a high temperature.",
      emoji: "🍕",
      category: "Italian",
      origin: "Italy"
    ),
    FoodItem(
      name: "Sushi",
      description:
        "A traditional Japanese dish of prepared vinegared rice, usually with some sugar and salt, accompanied by a variety of ingredients, such as seafood, often raw, and vegetables.",
      emoji: "🍣",
      category: "Japanese",
      origin: "Japan"
    ),
    FoodItem(
      name: "Tacos",
      description:
        "A traditional Mexican dish consisting of a small hand-sized corn or wheat tortilla topped with a filling. The tortilla is then folded around the filling and eaten by hand.",
      emoji: "🌮",
      category: "Mexican",
      origin: "Mexico"
    ),
    FoodItem(
      name: "Pasta",
      description:
        "A type of food typically made from an unleavened dough of wheat flour mixed with water or eggs, and formed into sheets or other shapes, then cooked by boiling or baking.",
      emoji: "🍝",
      category: "Italian",
      origin: "Italy"
    ),
    FoodItem(
      name: "Burger",
      description:
        "A sandwich consisting of one or more cooked patties of ground meat, usually beef, placed inside a sliced bread roll or bun. The patty may be pan fried, grilled, smoked or flame broiled.",
      emoji: "🍔",
      category: "American",
      origin: "United States"
    ),
    FoodItem(
      name: "Ramen",
      description:
        "A Japanese noodle soup dish. It consists of Chinese-style wheat noodles served in a meat or fish-based broth, often flavored with soy sauce or miso, and uses toppings such as sliced pork, nori, menma, and scallions.",
      emoji: "🍜",
      category: "Japanese",
      origin: "Japan"
    ),
    FoodItem(
      name: "Ice Cream",
      description:
        "A sweetened frozen food typically eaten as a snack or dessert. It may be made from dairy milk or cream and is flavoured with a sweetener, either sugar or an alternative, and any spice, such as cocoa or vanilla.",
      emoji: "🍦",
      category: "Dessert",
      origin: "Various"
    ),
    FoodItem(
      name: "Croissant",
      description:
        "A buttery, flaky, viennoiserie pastry of Austrian origin, but mostly associated with France. Croissants are named for their historical crescent shape and, like other viennoiserie, are made of a layered yeast-leavened dough.",
      emoji: "🥐",
      category: "French",
      origin: "Austria/France"
    ),
  ]
}

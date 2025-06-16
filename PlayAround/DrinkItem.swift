import Foundation

struct DrinkItem {
  let id = UUID()
  let name: String
  let description: String
  let emoji: String
  let category: String
  let origin: String

  static let sampleDrinks: [DrinkItem] = [
    DrinkItem(
      name: "Coffee",
      description:
        "A brewed drink prepared from roasted coffee beans, the seeds of berries from certain Coffea species. The genus Coffea is native to tropical Africa, and Madagascar, the Comoros, Mauritius, and Réunion in the Indian Ocean.",
      emoji: "☕",
      category: "Hot Beverage",
      origin: "Ethiopia"
    ),
    DrinkItem(
      name: "Green Tea",
      description:
        "A type of tea that is made from Camellia sinensis leaves and buds that have not undergone the same withering and oxidation process used to make oolong teas and black teas.",
      emoji: "🍵",
      category: "Tea",
      origin: "China"
    ),
    DrinkItem(
      name: "Fresh Orange Juice",
      description:
        "A liquid extract of the orange tree fruit, produced by squeezing or reaming oranges. It comes in several different varieties, including blood orange, navel oranges, valencia orange, clementine, and tangerine.",
      emoji: "🍊",
      category: "Fruit Juice",
      origin: "Various"
    ),
    DrinkItem(
      name: "Smoothie",
      description:
        "A drink made from pureed raw fruit and/or vegetables, using a blender. A smoothie often has a liquid base such as fruit juice, dairy products, such as milk, yogurt, ice cream or cottage cheese.",
      emoji: "🥤",
      category: "Blended Drink",
      origin: "United States"
    ),
    DrinkItem(
      name: "Bubble Tea",
      description:
        "A tea-based drink that originated in Taiwan in the early 1980s. It most commonly consists of tea accompanied by chewy tapioca balls, but it can be made with other toppings as well.",
      emoji: "🧋",
      category: "Tea",
      origin: "Taiwan"
    ),
    DrinkItem(
      name: "Hot Chocolate",
      description:
        "A heated drink consisting of shaved chocolate, melted chocolate or cocoa powder, heated milk or water, and usually a sweetener. Hot chocolate may be topped with whipped cream or marshmallows.",
      emoji: "🍫",
      category: "Hot Beverage",
      origin: "Mesoamerica"
    ),
  ]
}

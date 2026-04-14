import SwiftUI

func iconForCategory(_ category: String) -> String {
    let c = category.lowercased()

    if c.contains("coffee") { return "cup.and.saucer.fill" }
    if c.contains("grocer") { return "cart.fill" }
    if c.contains("rent") { return "house.fill" }
    if c.contains("util") { return "bolt.fill" }
    if c.contains("transport") || c.contains("gas") { return "car.fill" }
    if c.contains("food") || c.contains("dining") { return "fork.knife" }
    if c.contains("salary") || c.contains("pay") { return "banknote.fill" }
    if c.contains("fun") || c.contains("entertain") { return "party.popper.fill" }

    return "tag.fill"
}

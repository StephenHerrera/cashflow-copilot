//
//  CategoryIcon.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/5/26.
//

import SwiftUI

func iconForCategory(_ category: String) -> String {
    let c = category.lowercased()

    if c.contains("coffee") { return "cup.and.saucer.fill" }
    if c.contains("grocer") { return "cart.fill" }
    if c.contains("rent") { return "house.fill" }
    if c.contains("util") { return "bolt.fill" }
    if c.contains("transport") { return "car.fill" }
    if c.contains("food") { return "fork.knife" }

    return "tag.fill"
}

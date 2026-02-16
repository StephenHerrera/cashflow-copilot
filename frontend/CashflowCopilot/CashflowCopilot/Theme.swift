//
//  Theme.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/5/26.
//

import SwiftUI

enum AppTheme {
    // Finance-y, modern colors
    static let primary = Color.mint
    static let income = Color.green
    static let expense = Color.orange
    static let danger = Color.red
    static let cardBackground = Color(.secondarySystemBackground)
}

/// A reusable pill label
struct Pill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline)
            .monospacedDigit()
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(AppTheme.primary.opacity(0.15))
            .clipShape(Capsule())
    }
}

func currentMonthString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM"
    return formatter.string(from: Date())
}

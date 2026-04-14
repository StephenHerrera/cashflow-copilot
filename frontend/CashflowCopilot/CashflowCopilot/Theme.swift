import SwiftUI

enum AppTheme {
    static let primary = Color.mint
    static let income = Color.green
    static let expense = Color.orange
    static let danger = Color.red
    static let cardBackground = Color(.secondarySystemBackground)
}

/// Reusable pill label
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

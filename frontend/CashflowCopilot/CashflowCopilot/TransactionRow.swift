//
//  TransactionRow.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/5/26.
//

import SwiftUI

struct TransactionRow: View {
    let tx: TransactionItem

    var body: some View {
        Card {
            HStack(spacing: 12) {
                Image(systemName: iconForCategory(tx.category))
                    .font(.title3)
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 34)

                VStack(alignment: .leading, spacing: 4) {
                    Text(tx.description)
                        .font(.headline)
                        .lineLimit(1)

                    Text("\(tx.category.capitalized) • \(prettyDate(tx.date))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(formatCurrency(tx.amount))
                    .font(.headline)
                    .monospacedDigit()
                    .foregroundStyle(tx.amount >= 0 ? AppTheme.income : AppTheme.danger)
            }
        }
    }

    private func prettyDate(_ iso: String) -> String {
        // Your backend sends "YYYY-MM-DD"
        // We'll display it as "Feb 5"
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"

        let output = DateFormatter()
        output.dateFormat = "MMM d"

        if let d = input.date(from: iso) {
            return output.string(from: d)
        }
        return iso
    }
}

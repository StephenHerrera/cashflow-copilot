//
//  WrapChips.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/5/26.
//

import SwiftUI

struct WrapChips: View {
    let items: [String]

    var body: some View {
        // Simple wrap-like layout using LazyVGrid
        let columns = [
            GridItem(.adaptive(minimum: 90), spacing: 8)
        ]

        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(item.capitalized)
                    .font(.subheadline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(AppTheme.danger.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
    }
}

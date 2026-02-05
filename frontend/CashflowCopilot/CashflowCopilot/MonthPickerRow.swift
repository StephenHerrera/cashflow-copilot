//
//  MonthPickerRow.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/5/26.
//

import SwiftUI

struct MonthPickerRow: View {
    let title: String
    @Binding var selected: String
    let options: [String]

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()

            Picker(title, selection: $selected) {
                ForEach(options, id: \.self) { m in
                    Text(UIMonth(m)).tag(m)
                }
            }
            .pickerStyle(.menu) // dropdown
        }
    }
}

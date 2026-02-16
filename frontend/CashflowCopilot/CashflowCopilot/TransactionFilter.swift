//
//  TransactionFilter.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/5/26.
//

import Foundation

enum TransactionFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case income = "Income"
    case expenses = "Expenses"

    var id: String { rawValue }
}

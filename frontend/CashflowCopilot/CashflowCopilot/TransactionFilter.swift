import Foundation

enum TransactionFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case income = "Income"
    case expenses = "Expenses"

    var id: String { rawValue }
}

//
//  Models.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/4/26.
//
import Foundation

struct TransactionItem: Codable, Identifiable {
    let id: Int
    let amount: Double
    let description: String
    let category: String
    let date: String   // keep as String for now (we’ll parse later)
}

struct SummaryResponse: Codable {
    let total_income: Double
    let total_expenses: Double
    let net: Double
    let by_category: [String: Double]
    let transaction_count: Int
    let month_filtered: String?
    let budget_status: [String: BudgetStatus]
    let over_budget: [String]
}

struct BudgetStatus: Codable {
    let limit: Double
    let spent: Double
    let remaining: Double
    let percentage_used: Double
}

struct TrendItem: Codable, Identifiable {
    let month: String
    let income: Double
    let expenses: Double
    let net: Double

    var id: String { month }
}

struct BudgetItem: Codable, Identifiable {
    let id: Int
    let month: String
    let category: String
    let limit_amount: Double
}

struct CreateBudgetRequest: Codable {
    let month: String
    let category: String
    let limit_amount: Double
}

struct TrendRow: Codable, Identifiable {
    var id: String { month }
    let month: String
    let income: Double
    let expenses: Double
    let net: Double
}

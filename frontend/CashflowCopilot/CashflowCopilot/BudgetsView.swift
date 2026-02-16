//
//  BudgetsView.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/5/26.
//

import SwiftUI

struct BudgetsView: View {
    @State private var month: String = currentMonthString()
    private let monthOptions = lastNMonthsOptions(12)

    @State private var budgets: [BudgetItem] = []
    @State private var summary: SummaryResponse?

    @State private var isLoading = false
    @State private var errorText: String?

    @State private var showingAddBudget = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Month + actions
                    Card(title: "Month") {
                        MonthPickerRow(title: "Selected", selected: $month, options: monthOptions)

                        HStack(spacing: 12) {
                            Button {
                                Task { await load() }
                            } label: {
                                Label("Refresh", systemImage: "arrow.clockwise")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)

                            Button {
                                showingAddBudget = true
                            } label: {
                                Label("Add Budget", systemImage: "plus.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top, 6)
                    }

                    if isLoading {
                        Card { ProgressView("Loading budgets...") }
                    }

                    if let errorText {
                        Card {
                            Text(errorText)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    // Budget list
                    if budgets.isEmpty && !isLoading {
                        Card {
                            Text("No budgets found for \(UIMonth(month)).")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ForEach(budgets) { b in
                            BudgetRow(
                                category: b.category,
                                limit: b.limit_amount,
                                spent: spentForCategory(b.category),
                                monthLabel: UIMonth(b.month)
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Budgets")
            .task {
                await load()
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView(defaultMonth: month) {
                    Task { await load() }
                }
            }
        }
    }

    private func load() async {
        isLoading = true
        errorText = nil

        do {
            async let budgetTask = APIClient.shared.getBudgets(month: month)
            async let summaryTask = APIClient.shared.getSummary(month: month)

            budgets = try await budgetTask
            summary = try await summaryTask
        } catch {
            errorText = error.localizedDescription
        }

        isLoading = false
    }

    private func spentForCategory(_ cat: String) -> Double {
        let key = cat.lowercased()
        return summary?.by_category[key] ?? 0
    }
}

struct BudgetRow: View {
    let category: String
    let limit: Double
    let spent: Double
    let monthLabel: String

    var body: some View {
        let pct = (limit > 0) ? (spent / limit) : 0
        let pctClamped = min(max(pct, 0), 1)
        let over = spent > limit && limit > 0

        return Card {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(category.capitalized)
                        .font(.headline)
                    Spacer()
                    Text(monthLabel)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: pctClamped)
                    .tint(over ? AppTheme.danger : AppTheme.primary)

                HStack {
                    Text("Spent \(formatCurrency(spent))")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Limit \(formatCurrency(limit))")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)

                if over {
                    Text("Over budget by \(formatCurrency(spent - limit))")
                        .foregroundStyle(AppTheme.danger)
                        .font(.subheadline)
                }
            }
        }
    }
}

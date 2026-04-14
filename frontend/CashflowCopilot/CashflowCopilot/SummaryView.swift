import SwiftUI

struct SummaryView: View {
    @State private var month: String = currentMonthString()
    private let monthOptions = lastNMonthsOptions(12)

    @State private var summary: SummaryResponse?
    @State private var isLoading = false
    @State private var errorText: String?

    @State private var showTotals = true
    @State private var showOverBudget = true
    @State private var showByCategory = false
    @State private var showBudgetStatus = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    Card(title: "Month") {
                        MonthPickerRow(selectedMonth: $month, months: monthOptions)

                        Button {
                            Task { await loadSummary() }
                        } label: {
                            Label("Load Summary", systemImage: "arrow.down.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 6)
                    }

                    if isLoading {
                        Card { ProgressView("Loading...") }
                    }

                    if let errorText {
                        Card {
                            Text(errorText)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    if let summary {
                        Card {
                            DisclosureGroup(isExpanded: $showTotals) {
                                VStack(spacing: 10) {
                                    row("Income", summary.total_income, color: AppTheme.income)
                                    row("Expenses", summary.total_expenses, color: AppTheme.expense)
                                    row("Net", summary.net, color: summary.net >= 0 ? AppTheme.income : AppTheme.danger)

                                    Divider()

                                    Text("Transactions: \(summary.transaction_count)")
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.top, 6)
                            } label: {
                                Label("Totals", systemImage: "chart.bar.fill")
                                    .font(.headline)
                            }
                        }

                        Card {
                            DisclosureGroup(isExpanded: $showOverBudget) {
                                if summary.over_budget.isEmpty {
                                    Text("None 🎉")
                                        .foregroundStyle(.secondary)
                                        .padding(.top, 6)
                                } else {
                                    WrapChips(items: summary.over_budget)
                                        .padding(.top, 6)
                                }
                            } label: {
                                Label("Over Budget", systemImage: "exclamationmark.triangle.fill")
                                    .foregroundStyle(summary.over_budget.isEmpty ? .primary : AppTheme.danger)
                                    .font(.headline)
                            }
                        }

                        Card {
                            DisclosureGroup(isExpanded: $showByCategory) {
                                VStack(spacing: 10) {
                                    ForEach(summary.by_category.keys.sorted(), id: \.self) { key in
                                        let value = summary.by_category[key] ?? 0
                                        HStack {
                                            Text(key.capitalized)
                                            Spacer()
                                            Text(formatCurrency(value))
                                                .monospacedDigit()
                                        }
                                    }
                                }
                                .padding(.top, 6)
                            } label: {
                                Label("By Category", systemImage: "tag.fill")
                                    .font(.headline)
                            }
                        }

                        Card {
                            DisclosureGroup(isExpanded: $showBudgetStatus) {
                                if summary.budget_status.isEmpty {
                                    Text("No budgets set for \(prettyMonth(month)).")
                                        .foregroundStyle(.secondary)
                                        .padding(.top, 6)
                                } else {
                                    VStack(spacing: 12) {
                                        ForEach(summary.budget_status.keys.sorted(), id: \.self) { key in
                                            if let b = summary.budget_status[key] {
                                                BudgetStatusRow(
                                                    category: key,
                                                    spent: b.spent,
                                                    limit: b.limit,
                                                    percentageUsed: b.percentage_used
                                                )
                                            }
                                        }
                                    }
                                    .padding(.top, 6)
                                }
                            } label: {
                                Label("Budget Status", systemImage: "target")
                                    .font(.headline)
                            }
                        }

                    } else if !isLoading {
                        Card {
                            Text("Pick a month and load your summary.")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Summary")
            .refreshable { await loadSummary() }
            .task { await loadSummary() }
            .onChange(of: month) { _, _ in
                Task { await loadSummary() }
            }
        }
    }

    private func loadSummary() async {
        isLoading = true
        errorText = nil
        summary = nil

        do {
            summary = try await APIClient.shared.getSummary(month: month)
        } catch {
            errorText = error.localizedDescription
        }

        isLoading = false
    }

    private func row(_ label: String, _ amount: Double, color: Color) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(formatCurrency(amount))
                .monospacedDigit()
                .foregroundStyle(color)
        }
    }
}

struct BudgetStatusRow: View {
    let category: String
    let spent: Double
    let limit: Double
    let percentageUsed: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(category.capitalized)
                    .font(.headline)
                Spacer()
                Text("\(String(format: "%.0f", percentageUsed))%")
                    .foregroundStyle(percentageUsed >= 100 ? AppTheme.danger : .secondary)
                    .monospacedDigit()
            }

            ProgressView(value: min(spent / max(limit, 0.01), 1.0))
                .tint(percentageUsed >= 100 ? AppTheme.danger : AppTheme.primary)

            HStack {
                Text("Spent \(formatCurrency(spent))")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Limit \(formatCurrency(limit))")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
    }
}

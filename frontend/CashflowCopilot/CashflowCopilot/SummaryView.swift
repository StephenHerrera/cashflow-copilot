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
                    monthCard

                    if isLoading && summary == nil {
                        loadingCard
                    }

                    if let errorText {
                        errorCard(errorText)
                    }

                    if let summary {
                        totalsCard(summary)
                        overBudgetCard(summary)
                        byCategoryCard(summary)
                        budgetStatusCard(summary)
                    } else if !isLoading {
                        emptyStateCard
                    }
                }
                .padding()
            }
            .navigationTitle("Summary")
            .background(Color(.systemGroupedBackground))
            .refreshable {
                await loadSummary()
            }
            .task {
                await loadSummary()
            }
            .onChange(of: month) { _, _ in
                Task { await loadSummary() }
            }
        }
    }

    // MARK: - Sections

    private var monthCard: some View {
        Card(title: "Month") {
            VStack(spacing: 12) {
                MonthPickerRow(
                    title: "Month",
                    selectedMonth: $month,
                    months: monthOptions,
                    defaultMonth: currentMonthString()
                )

                Button {
                    Task { await loadSummary() }
                } label: {
                    Label("Load Summary", systemImage: "arrow.down.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var loadingCard: some View {
        Card {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading summary...")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func errorCard(_ message: String) -> some View {
        Card {
            Text(message)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var emptyStateCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 6) {
                Text("No summary available")
                    .font(.headline)

                Text("Pick a month and load your summary.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func totalsCard(_ summary: SummaryResponse) -> some View {
        Card {
            DisclosureGroup(isExpanded: $showTotals) {
                VStack(spacing: 12) {
                    metricRow(
                        title: "Income",
                        value: summary.total_income,
                        color: AppTheme.income
                    )

                    metricRow(
                        title: "Expenses",
                        value: summary.total_expenses,
                        color: AppTheme.expense
                    )

                    metricRow(
                        title: "Net",
                        value: summary.net,
                        color: summary.net >= 0 ? AppTheme.income : AppTheme.danger,
                        isBold: true
                    )

                    Divider()

                    HStack {
                        Label("Transactions", systemImage: "list.bullet")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(summary.transaction_count)")
                            .monospacedDigit()
                    }
                }
                .padding(.top, 8)
            } label: {
                Label("Totals", systemImage: "chart.bar.fill")
                    .font(.headline)
            }
        }
    }

    private func overBudgetCard(_ summary: SummaryResponse) -> some View {
        Card {
            DisclosureGroup(isExpanded: $showOverBudget) {
                if summary.over_budget.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppTheme.income)

                        Text("No categories are over budget for \(prettyMonth(month)).")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                } else {
                    WrapChips(items: summary.over_budget)
                        .padding(.top, 8)
                }
            } label: {
                Label("Over Budget", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(summary.over_budget.isEmpty ? .primary : AppTheme.danger)
            }
        }
    }

    private func byCategoryCard(_ summary: SummaryResponse) -> some View {
        Card {
            DisclosureGroup(isExpanded: $showByCategory) {
                VStack(spacing: 10) {
                    ForEach(summary.by_category.keys.sorted(), id: \.self) { key in
                        let value = summary.by_category[key] ?? 0

                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: iconForCategory(key))
                                    .foregroundStyle(AppTheme.primary)

                                Text(key.capitalized)
                            }

                            Spacer()

                            Text(formatCurrency(value))
                                .monospacedDigit()
                        }
                    }
                }
                .padding(.top, 8)
            } label: {
                Label("By Category", systemImage: "tag.fill")
                    .font(.headline)
            }
        }
    }

    private func budgetStatusCard(_ summary: SummaryResponse) -> some View {
        Card {
            DisclosureGroup(isExpanded: $showBudgetStatus) {
                if summary.budget_status.isEmpty {
                    Text("No budgets set for \(prettyMonth(month)).")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                } else {
                    VStack(spacing: 12) {
                        ForEach(summary.budget_status.keys.sorted(), id: \.self) { key in
                            if let budget = summary.budget_status[key] {
                                BudgetStatusRow(
                                    category: key,
                                    spent: budget.spent,
                                    limit: budget.limit,
                                    percentageUsed: budget.percentage_used
                                )
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            } label: {
                Label("Budget Status", systemImage: "target")
                    .font(.headline)
            }
        }
    }

    // MARK: - Helpers

    private func loadSummary() async {
        isLoading = true
        errorText = nil

        do {
            summary = try await APIClient.shared.getSummary(month: month)
        } catch {
            errorText = error.localizedDescription
        }

        isLoading = false
    }

    private func metricRow(
        title: String,
        value: Double,
        color: Color,
        isBold: Bool = false
    ) -> some View {
        HStack {
            Text(title)

            Spacer()

            Text(formatCurrency(value))
                .monospacedDigit()
                .fontWeight(isBold ? .semibold : .regular)
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: iconForCategory(category))
                        .foregroundStyle(AppTheme.primary)

                    Text(category.capitalized)
                        .font(.headline)
                }

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

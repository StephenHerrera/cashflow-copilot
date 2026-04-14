import SwiftUI
import Charts

struct TrendView: View {
    @State private var monthsToShow: Int = 6
    @State private var rows: [TrendRow] = []
    @State private var isLoading = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    Card(title: "Range") {
                        HStack {
                            Text("Show")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Picker("Months", selection: $monthsToShow) {
                                Text("3 months").tag(3)
                                Text("6 months").tag(6)
                                Text("12 months").tag(12)
                            }
                            .pickerStyle(.menu)
                        }

                        Button {
                            Task { await load() }
                        } label: {
                            Label("Refresh Trend", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 6)
                    }

                    if isLoading {
                        Card { ProgressView("Loading trend...") }
                    }

                    if let errorText {
                        Card {
                            Text(errorText)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    if !rows.isEmpty {
                        NetLineChartCard(rows: rows)
                        IncomeExpenseBarChartCard(rows: rows)
                    }

                    if rows.isEmpty && !isLoading {
                        Card {
                            Text("No trend data yet.")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ForEach(rows) { r in
                            TrendRowCard(row: r)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Trend")
            .refreshable { await load() }
            .task { await load() }
            .onChange(of: monthsToShow) { _, _ in
                Task { await load() }
            }
        }
    }

    private func load() async {
        isLoading = true
        errorText = nil

        do {
            rows = try await APIClient.shared.getTrend(months: monthsToShow)
        } catch {
            errorText = error.localizedDescription
        }

        isLoading = false
    }
}

struct NetLineChartCard: View {
    let rows: [TrendRow]

    var body: some View {
        Card(title: "Net Trend") {
            Chart(rows) { r in
                LineMark(
                    x: .value("Month", prettyMonth(r.month)),
                    y: .value("Net", r.net)
                )
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Month", prettyMonth(r.month)),
                    y: .value("Net", r.net)
                )
            }
            .frame(height: 190)
            .chartYAxis { AxisMarks(position: .leading) }

            let totalNet = rows.reduce(0) { $0 + $1.net }
            HStack {
                Text("Total net (\(rows.count) mo)")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(formatCurrency(totalNet))
                    .bold()
                    .monospacedDigit()
                    .foregroundStyle(totalNet >= 0 ? AppTheme.income : AppTheme.danger)
            }
            .padding(.top, 8)
        }
    }
}

struct IncomeExpenseBarChartCard: View {
    let rows: [TrendRow]

    var body: some View {
        Card(title: "Income vs Expenses") {
            Chart(rows) { r in
                BarMark(
                    x: .value("Month", prettyMonth(r.month)),
                    y: .value("Income", r.income)
                )
                .foregroundStyle(AppTheme.income)

                BarMark(
                    x: .value("Month", prettyMonth(r.month)),
                    y: .value("Expenses", abs(r.expenses))
                )
                .foregroundStyle(AppTheme.expense)
            }
            .frame(height: 220)
            .chartYAxis { AxisMarks(position: .leading) }
            .chartLegend(position: .bottom, alignment: .leading)
        }
    }
}

struct TrendRowCard: View {
    let row: TrendRow

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text(prettyMonth(row.month))
                    .font(.headline)

                HStack {
                    metric("Income", row.income, AppTheme.income)
                    metric("Expenses", row.expenses, AppTheme.expense)
                    metric("Net", row.net, row.net >= 0 ? AppTheme.income : AppTheme.danger)
                }
            }
        }
    }

    private func metric(_ label: String, _ value: Double, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(formatCurrency(value))
                .font(.subheadline)
                .bold()
                .monospacedDigit()
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

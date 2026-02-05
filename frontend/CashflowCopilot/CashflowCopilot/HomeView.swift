import SwiftUI

struct HomeView: View {
    @State private var month: String = currentMonthString()
    @State private var summary: SummaryResponse?
    @State private var isLoading = false
    @State private var errorText: String?
    
    // Quick action sheets
    @State private var showingAddTransaction = false
    @State private var showingAddBudget = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // ---------- Brand Header ----------
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [AppTheme.primary.opacity(0.9), AppTheme.primary.opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cashflow Copilot")
                                .font(.title)
                                .bold()
                                .foregroundStyle(.white)
                            
                            Text("Your monthly money dashboard")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.9))
                            
                            HStack(spacing: 8) {
                                Pill(text: UIMonth(month))
                                    .foregroundStyle(.white)
                                
                                Button {
                                    Task { await load() }
                                } label: {
                                    Label("Refresh", systemImage: "arrow.clockwise")
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.white.opacity(0.25))
                            }
                        }
                        .padding()
                    }
                    
                    // ---------- Quick Actions ----------
                    Card(title: "Quick Actions") {
                        HStack(spacing: 12) {
                            Button {
                                showingAddTransaction = true
                            } label: {
                                Label("Add Transaction", systemImage: "plus.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button {
                                showingAddBudget = true
                            } label: {
                                Label("Add Budget", systemImage: "target")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    // ---------- Loading / Error ----------
                    if isLoading {
                        Card {
                            ProgressView("Loading your dashboard...")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    if let errorText {
                        Card {
                            Text(errorText)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    // ---------- Dashboard Content ----------
                    if let summary {
                        // Metric row (different layout than Summary)
                        HStack(spacing: 12) {
                            metricCard(title: "Income", amount: summary.total_income, color: AppTheme.income)
                            metricCard(title: "Expenses", amount: summary.total_expenses, color: AppTheme.expense)
                            metricCard(title: "Net", amount: summary.net, color: summary.net >= 0 ? AppTheme.income : AppTheme.danger)
                        }
                        
                        // Over budget alert
                        if !summary.over_budget.isEmpty {
                            Card {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(AppTheme.danger)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Over budget")
                                            .font(.headline)
                                        Text("You’re over budget in:")
                                            .foregroundStyle(.secondary)
                                        WrapChips(items: summary.over_budget)
                                    }
                                }
                            }
                        } else {
                            Card {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundStyle(AppTheme.income)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Budgets look good")
                                            .font(.headline)
                                        Text("No categories are over budget for \(UIMonth(month)).")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        
                        // Top spend category (fun + useful)
                        Card(title: "Top Spending Category") {
                            if let top = topCategory(summary.by_category) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(top.name.capitalized)
                                            .font(.headline)
                                        Text("Spent this month")
                                            .foregroundStyle(.secondary)
                                            .font(.subheadline)
                                    }
                                    Spacer()
                                    Text(formatCurrency(top.amount))
                                        .font(.headline)
                                        .monospacedDigit()
                                }
                            } else {
                                Text("No spending data yet.")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // Small footer
                        Text("Transactions this month: \(summary.transaction_count)")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    } else if !isLoading {
                        Card {
                            Text("No data yet. Add a transaction to get started.")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .task { await load() }
        // Hook into existing add screens
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetView(defaultMonth: month) {
                Task { await load() }
            }
        }
    }
    
    private func load() async {
        isLoading = true
        errorText = nil
        
        do {
            summary = try await APIClient.shared.getSummary(month: month)
        } catch {
            errorText = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func metricCard(title: String, amount: Double, color: Color) -> some View {
        Card {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(formatCurrency(amount))
                .font(.headline)
                .bold()
                .monospacedDigit()
            
            Rectangle()
                .frame(height: 4)
                .foregroundStyle(color.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 3))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func topCategory(_ dict: [String: Double]) -> (name: String, amount: Double)? {
        dict.max { a, b in a.value < b.value }.map { ($0.key, $0.value) }
    }
}

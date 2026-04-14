import SwiftUI

struct BudgetsView: View {
    @State private var selectedMonth: String = currentMonthString()
    @State private var budgets: [BudgetItem] = []
    @State private var isLoading = false
    @State private var errorText: String?

    @State private var showingAddBudget = false

    @State private var editingBudget: BudgetItem?
    @State private var showEditSheet = false

    @State private var confirmDelete: BudgetItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Card(title: "Month") {
                        MonthPickerRow(selectedMonth: $selectedMonth, months: lastNMonthsOptions(12))
                    }

                    if isLoading {
                        Card { ProgressView("Loading budgets...") }
                    }

                    if let errorText {
                        Card { Text(errorText).foregroundStyle(.red) }
                    }

                    if budgets.isEmpty && !isLoading {
                        Card { Text("No budgets set. Tap + to add one.").foregroundStyle(.secondary) }
                    } else {
                        ForEach(budgets) { budget in
                            BudgetCard(budget: budget)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        confirmDelete = budget
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        editingBudget = budget
                                        showEditSheet = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddBudget = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable { await loadBudgets() }
            .task { await loadBudgets() }
            .onChange(of: selectedMonth) { _, _ in
                Task { await loadBudgets() }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView(defaultMonth: selectedMonth) {
                    Task { await loadBudgets() }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                if let editingBudget {
                    EditBudgetView(budget: editingBudget) {
                        Task { await loadBudgets() }
                    }
                }
            }
            .alert("Delete budget?", isPresented: .constant(confirmDelete != nil)) {
                Button("Delete", role: .destructive) {
                    if let b = confirmDelete {
                        Task { await deleteBudget(b) }
                    }
                    confirmDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    confirmDelete = nil
                }
            } message: {
                Text("This cannot be undone.")
            }
        }
    }

    private func loadBudgets() async {
        isLoading = true
        errorText = nil
        do {
            budgets = try await APIClient.shared.getBudgets(month: selectedMonth)
        } catch {
            errorText = error.localizedDescription
        }
        isLoading = false
    }

    private func deleteBudget(_ budget: BudgetItem) async {
        do {
            try await APIClient.shared.deleteBudget(id: budget.id)
            await loadBudgets()
        } catch {
            errorText = error.localizedDescription
        }
    }
}

struct BudgetCard: View {
    let budget: BudgetItem

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 8) {
                Text(budget.category.capitalized)
                    .font(.headline)

                HStack {
                    Text(prettyMonth(budget.month))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(formatCurrency(budget.limit_amount))
                        .bold()
                        .monospacedDigit()
                }
            }
        }
    }
}

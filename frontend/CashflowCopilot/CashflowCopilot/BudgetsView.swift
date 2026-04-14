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
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Card(title: "Month") {
                        MonthPickerRow(
                            title: "Month",
                            selectedMonth: $selectedMonth,
                            months: lastNMonthsOptions(12),
                            defaultMonth: currentMonthString()
                        )
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                if isLoading {
                    Section {
                        Card {
                            ProgressView("Loading budgets...")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }

                if let errorText {
                    Section {
                        Card {
                            Text(errorText)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }

                Section {
                    if budgets.isEmpty && !isLoading {
                        Card {
                            Text("No budgets set. Tap + to add one.")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(budgets) { budget in
                            BudgetCard(budget: budget)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        confirmDelete = budget
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        editingBudget = budget
                                        showEditSheet = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(AppTheme.primary)
                                }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddBudget = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                await loadBudgets()
            }
            .task {
                await loadBudgets()
            }
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
                    EditBudgetsView(budget: editingBudget) {
                        Task { await loadBudgets() }
                    }
                }
            }
            .alert("Delete budget?", isPresented: $showingDeleteAlert, presenting: confirmDelete) { budget in
                Button("Delete", role: .destructive) {
                    Task { await deleteBudget(budget) }
                }

                Button("Cancel", role: .cancel) {
                    confirmDelete = nil
                }
            } message: { budget in
                Text("Are you sure you want to delete the \(budget.category.capitalized) budget for \(prettyMonth(budget.month))?")
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
            confirmDelete = nil
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

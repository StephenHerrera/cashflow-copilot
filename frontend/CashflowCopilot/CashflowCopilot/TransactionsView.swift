import SwiftUI

struct TransactionsView: View {
    @State private var transactions: [TransactionItem] = []
    @State private var isLoading = false
    @State private var errorText: String?

    @State private var searchText: String = ""
    @State private var filter: TransactionFilter = .all

    @State private var showingAddSheet = false

    @State private var selectedTransaction: TransactionItem?
    @State private var showingEditSheet = false

    @State private var transactionToDelete: TransactionItem?
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Card(title: "Browse") {
                        TextField("Search description...", text: $searchText)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            Text("Filter")
                                .foregroundStyle(.secondary)

                            Spacer()

                            Picker("Filter", selection: $filter) {
                                ForEach(TransactionFilter.allCases) { f in
                                    Text(f.rawValue).tag(f)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                if isLoading {
                    Section {
                        Card {
                            ProgressView("Loading transactions...")
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
                    if filteredTransactions.isEmpty && !isLoading {
                        Card {
                            Text("No transactions found.")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredTransactions) { tx in
                            TransactionRow(tx: tx)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        transactionToDelete = tx
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        selectedTransaction = tx
                                        showingEditSheet = true
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
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Refresh") {
                        Task { await loadTransactions() }
                    }
                }
            }
            .refreshable {
                await loadTransactions()
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView()
        }
        .sheet(isPresented: $showingEditSheet) {
            if let selectedTransaction {
                EditTransactionView(transaction: selectedTransaction) {
                    Task { await loadTransactions() }
                }
            }
        }
        .alert("Delete transaction?", isPresented: $showingDeleteAlert, presenting: transactionToDelete) { tx in
            Button("Delete", role: .destructive) {
                Task { await delete(tx) }
            }

            Button("Cancel", role: .cancel) {
                transactionToDelete = nil
            }
        } message: { tx in
            Text("Are you sure you want to delete “\(tx.description)”?")
        }
        .task {
            await loadTransactions()
        }
    }

    private var filteredTransactions: [TransactionItem] {
        var result = transactions

        switch filter {
        case .all:
            break
        case .income:
            result = result.filter { $0.amount >= 0 }
        case .expenses:
            result = result.filter { $0.amount < 0 }
        }

        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if !query.isEmpty {
            result = result.filter {
                $0.description.lowercased().contains(query) ||
                $0.category.lowercased().contains(query)
            }
        }

        return result
    }

    private func loadTransactions() async {
        isLoading = true
        errorText = nil

        do {
            transactions = try await APIClient.shared.getTransactions()
        } catch {
            errorText = error.localizedDescription
        }

        isLoading = false
    }

    private func delete(_ tx: TransactionItem) async {
        do {
            try await APIClient.shared.deleteTransaction(id: tx.id)
            transactionToDelete = nil
            await loadTransactions()
        } catch {
            errorText = error.localizedDescription
        }
    }
}

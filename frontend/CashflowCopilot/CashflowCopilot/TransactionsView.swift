import SwiftUI

struct TransactionsView: View {
    @State private var transactions: [TransactionItem] = []
    @State private var isLoading = false
    @State private var errorText: String?

    @State private var searchText: String = ""
    @State private var filter: TransactionFilter = .all

    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Controls card (search + dropdown)
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
                            .pickerStyle(.menu) // <-- dropdown
                        }
                    }

                    if isLoading {
                        Card {
                            ProgressView("Loading transactions...")
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

                    // Results
                    if filteredTransactions.isEmpty && !isLoading {
                        Card {
                            Text("No transactions found.")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ForEach(filteredTransactions) { tx in
                            TransactionRow(tx: tx)
                        }
                    }
                }
                .padding()
            }
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
            .sheet(isPresented: $showingAddSheet) {
                AddTransactionView()
            }
            .task {
                await loadTransactions()
            }
        }
    }

    private var filteredTransactions: [TransactionItem] {
        var result = transactions

        // Dropdown filter
        switch filter {
        case .all:
            break
        case .income:
            result = result.filter { $0.amount >= 0 }
        case .expenses:
            result = result.filter { $0.amount < 0 }
        }

        // Search filter
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchText.lowercased()
            result = result.filter { $0.description.lowercased().contains(q) }
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
}

//
//  EditTransactionView.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/5/26.
//

import SwiftUI

struct EditTransactionView: View {
    let transaction: TransactionItem
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var amountText: String = ""
    @State private var descriptionText: String = ""
    @State private var categoryText: String = ""
    @State private var dateText: String = "" // YYYY-MM-DD

    @State private var isSaving = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Description", text: $descriptionText)
                    TextField("Category (ex: groceries)", text: $categoryText)
                        .textInputAutocapitalization(.never)

                    TextField("Amount (ex: -12.50)", text: $amountText)
                        .keyboardType(.decimalPad)

                    TextField("Date (YYYY-MM-DD)", text: $dateText)
                        .textInputAutocapitalization(.never)
                }

                if let errorText {
                    Section {
                        Text(errorText).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Edit Transaction")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(isSaving ? "Saving..." : "Save") {
                        Task { await save() }
                    }
                    .disabled(isSaving)
                }
            }
            .onAppear {
                amountText = String(transaction.amount)
                descriptionText = transaction.description
                categoryText = transaction.category
                dateText = transaction.date
            }
        }
    }

    private func save() async {
        isSaving = true
        errorText = nil

        guard let amount = Double(amountText) else {
            errorText = "Amount must be a number."
            isSaving = false
            return
        }

        let req = UpdateTransactionRequest(
            amount: amount,
            description: descriptionText,
            category: categoryText,
            date: dateText
        )

        do {
            try await APIClient.shared.updateTransaction(id: transaction.id, request: req)
            onSaved()
            dismiss()
        } catch {
            errorText = error.localizedDescription
        }

        isSaving = false
    }
}

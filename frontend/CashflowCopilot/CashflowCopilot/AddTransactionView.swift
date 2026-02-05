//
//  AddTransactionView.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/4/26.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss

    @State private var description = ""
    @State private var amount = ""
    @State private var isSaving = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Description", text: $description)

                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)

                if let errorText {
                    Text(errorText)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await saveTransaction() }
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveTransaction() async {
        guard let amountValue = Double(amount) else {
            errorText = "Invalid amount."
            return
        }

        isSaving = true
        errorText = nil

        let today = ISO8601DateFormatter().string(from: Date())
            .prefix(10) // gives YYYY-MM-DD

        let request = CreateTransactionRequest(
            amount: amountValue,
            description: description,
            date: String(today)
        )

        do {
            try await APIClient.shared.createTransaction(request: request)
            dismiss()
        } catch {
            errorText = error.localizedDescription
        }

        isSaving = false
    }
}

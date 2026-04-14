import SwiftUI

struct EditTransactionView: View {
    let transaction: TransactionItem
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var amountText: String = ""
    @State private var descriptionText: String = ""
    @State private var categoryText: String = ""
    @State private var dateValue: Date = Date()

    @State private var isSaving = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Description", text: $descriptionText)

                    TextField("Category", text: $categoryText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    TextField("Amount (ex: -12.50)", text: $amountText)
                        .keyboardType(.decimalPad)

                    DatePicker("Date", selection: $dateValue, displayedComponents: [.date])
                }

                if let errorText {
                    Section {
                        Text(errorText).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Edit Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
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

                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                if let d = df.date(from: transaction.date) {
                    dateValue = d
                }
            }
        }
    }

    private func save() async {
        errorText = nil

        guard let amount = Double(amountText.trimmed) else {
            errorText = "Amount must be a number."
            return
        }

        if descriptionText.trimmed.isEmpty {
            errorText = "Description is required."
            return
        }

        if categoryText.trimmed.isEmpty {
            errorText = "Category is required."
            return
        }

        isSaving = true

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"

        let req = UpdateTransactionRequest(
            amount: amount,
            description: descriptionText.trimmed,
            category: categoryText.trimmed.lowercased(),
            date: df.string(from: dateValue)
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

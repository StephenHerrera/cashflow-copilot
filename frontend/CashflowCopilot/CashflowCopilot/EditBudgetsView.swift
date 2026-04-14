import SwiftUI

struct EditBudgetsView: View {
    let budget: BudgetItem
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var monthText: String = ""
    @State private var categoryText: String = ""
    @State private var limitText: String = ""

    @State private var isSaving = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Budget Details") {
                    TextField("Month (YYYY-MM)", text: $monthText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    TextField("Category", text: $categoryText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    TextField("Limit Amount", text: $limitText)
                        .keyboardType(.decimalPad)
                }

                if let errorText {
                    Section {
                        Text(errorText)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Edit Budget")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(isSaving ? "Saving..." : "Save") {
                        Task { await save() }
                    }
                    .disabled(isSaving)
                }
            }
            .onAppear {
                monthText = budget.month
                categoryText = budget.category
                limitText = String(budget.limit_amount)
            }
        }
    }

    private func save() async {
        errorText = nil

        guard let limitValue = Double(limitText) else {
            errorText = "Limit must be a valid number."
            return
        }

        isSaving = true

        let request = UpdateBudgetRequest(
            month: monthText,
            category: categoryText,
            limit_amount: limitValue
        )

        do {
            try await APIClient.shared.updateBudget(id: budget.id, request: request)
            onSaved()
            dismiss()
        } catch {
            errorText = error.localizedDescription
        }

        isSaving = false
    }
}

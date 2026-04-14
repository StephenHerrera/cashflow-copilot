import SwiftUI

struct EditBudgetView: View {
    let budget: BudgetItem
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var category: String
    @State private var limitText: String
    @State private var month: String

    @State private var isSaving = false
    @State private var errorText: String?

    init(budget: BudgetItem, onSaved: @escaping () -> Void) {
        self.budget = budget
        self.onSaved = onSaved
        _category = State(initialValue: budget.category)
        _limitText = State(initialValue: String(budget.limit_amount))
        _month = State(initialValue: budget.month)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Budget") {
                    TextField("Category", text: $category)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    TextField("Limit", text: $limitText)
                        .keyboardType(.decimalPad)

                    Picker("Month", selection: $month) {
                        ForEach(lastNMonthsOptions(12), id: \.self) { m in
                            Text(prettyMonth(m)).tag(m)
                        }
                    }
                }

                if let errorText {
                    Section { Text(errorText).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Edit Budget")
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
        }
    }

    private func save() async {
        errorText = nil

        if category.trimmed.isEmpty {
            errorText = "Category is required."
            return
        }

        guard let limitAmount = Double(limitText.trimmed) else {
            errorText = "Limit must be a number."
            return
        }

        isSaving = true
        do {
            let req = UpdateBudgetRequest(
                month: month,
                category: category.trimmed.lowercased(),
                limit_amount: limitAmount
            )
            try await APIClient.shared.updateBudget(id: budget.id, request: req)
            onSaved()
            dismiss()
        } catch {
            errorText = error.localizedDescription
        }
        isSaving = false
    }
}

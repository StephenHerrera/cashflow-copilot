import SwiftUI

struct AddBudgetView: View {
    let defaultMonth: String
    let onSaved: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var month: String
    @State private var category: String = ""
    @State private var limitAmount: String = ""

    @State private var isSaving = false
    @State private var errorText: String?

    private let monthOptions = lastNMonthsOptions(12)

    init(defaultMonth: String, onSaved: (() -> Void)? = nil) {
        self.defaultMonth = defaultMonth
        self.onSaved = onSaved
        _month = State(initialValue: defaultMonth)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Month") {
                    Picker("Month", selection: $month) {
                        ForEach(monthOptions, id: \.self) { m in
                            Text(prettyMonth(m)).tag(m)
                        }
                    }
                }

                Section("Budget") {
                    TextField("Category (ex: groceries)", text: $category)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    TextField("Limit Amount", text: $limitAmount)
                        .keyboardType(.decimalPad)
                }

                if let errorText {
                    Section {
                        Text(errorText)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Budget")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Saving..." : "Save") {
                        Task { await save() }
                    }
                    .disabled(isSaving || category.trimmed.isEmpty || limitAmount.trimmed.isEmpty)
                }
            }
        }
    }

    private func save() async {
        errorText = nil

        guard !category.trimmed.isEmpty else {
            errorText = "Please enter a category."
            return
        }

        guard let limit = Double(limitAmount.trimmed) else {
            errorText = "Limit must be a number."
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            try await APIClient.shared.createOrUpdateBudget(
                request: CreateBudgetRequest(
                    month: month,
                    category: category.trimmed.lowercased(),
                    limit_amount: limit
                )
            )
            onSaved?()
            dismiss()
        } catch {
            errorText = error.localizedDescription
        }
    }
}

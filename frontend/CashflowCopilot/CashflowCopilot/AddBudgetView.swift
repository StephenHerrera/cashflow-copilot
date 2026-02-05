//
//  AddBudgetView.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/5/26.
//

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

    init(defaultMonth: String, onSaved: (() -> Void)? = nil) {
        self.defaultMonth = defaultMonth
        self.onSaved = onSaved
        _month = State(initialValue: defaultMonth)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Month") {
                    Text(UIMonth(month))
                        .foregroundStyle(.secondary)
                    TextField("YYYY-MM (example: 2026-02)", text: $month)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
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
        }
    }

    private func save() async {
        errorText = nil

        guard !category.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorText = "Please enter a category."
            return
        }

        guard let limit = Double(limitAmount) else {
            errorText = "Limit must be a number."
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            try await APIClient.shared.createOrUpdateBudget(
                request: CreateBudgetRequest(
                    month: month,
                    category: category,
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

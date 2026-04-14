import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var description = ""
    @State private var category = ""
    @State private var amount = ""
    @State private var date = Date()
    
    @State private var isSaving = false
    @State private var errorText: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Description", text: $description)
                    
                    TextField("Category (optional)", text: $category)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    TextField("Amount (ex: -12.50)", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                }
                
                if let errorText {
                    Section {
                        Text(errorText)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Saving..." : "Save") {
                        Task { await saveTransaction() }
                    }
                    .disabled(isSaving || description.trimmed.isEmpty || amount.trimmed.isEmpty)
                }
            }
        }
    }
    
    private func saveTransaction() async {
        guard let amountValue = Double(amount.trimmed) else {
            errorText = "Amount must be a number."
            return
        }
        
        isSaving = true
        errorText = nil
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        let request = CreateTransactionRequest(
            amount: amountValue,
            description: description.trimmed,
            category: category.trimmed.isEmpty ? nil : category.trimmed.lowercased(),
            date: df.string(from: date)
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

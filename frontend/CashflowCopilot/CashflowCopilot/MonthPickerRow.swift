import SwiftUI

struct MonthPickerRow: View {
    private let selectedMonth: Binding<String>
    private let months: [String]
    private let defaultMonth: String
    private let onMonthChanged: (String) -> Void

    @State private var internalMonth: String

    init(
        selectedMonth: Binding<String>,
        months: [String] = lastNMonthsOptions(),
        defaultMonth: String = currentMonthString(),
        onMonthChanged: @escaping (String) -> Void = { _ in }
    ) {
        self.selectedMonth = selectedMonth
        self.months = months
        self.defaultMonth = defaultMonth
        self.onMonthChanged = onMonthChanged
        _internalMonth = State(initialValue: defaultMonth)
    }

    // legacy initializer: MonthPickerRow(months, defaultMonth, onChange)
    init(
        _ months: [String],
        _ defaultMonth: String,
        _ onMonthChanged: @escaping (String) -> Void
    ) {
        self.months = months
        self.defaultMonth = defaultMonth
        self.onMonthChanged = onMonthChanged

        let state = State(initialValue: defaultMonth)
        self._internalMonth = state
        self.selectedMonth = state.projectedValue
    }

    var body: some View {
        HStack {
            Text("Month")
                .foregroundStyle(.secondary)

            Spacer()

            Picker("Month", selection: selectedMonth) {
                ForEach(months, id: \.self) { m in
                    Text(prettyMonth(m))
                        .tag(m)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedMonth.wrappedValue) { _, newValue in
                onMonthChanged(newValue)
            }

            Button {
                selectedMonth.wrappedValue = defaultMonth
                onMonthChanged(defaultMonth)
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.leading, 6)
        }
    }
}

import SwiftUI

struct MonthPickerRow: View {
    private let title: String
    private let months: [String]
    private let defaultMonth: String
    private let onMonthChanged: (String) -> Void

    @Binding private var selectedMonth: String

    init(
        title: String = "Month",
        selectedMonth: Binding<String>,
        months: [String] = lastNMonthsOptions(),
        defaultMonth: String = currentMonthString(),
        onMonthChanged: @escaping (String) -> Void = { _ in }
    ) {
        self.title = title
        self._selectedMonth = selectedMonth
        self.months = months
        self.defaultMonth = defaultMonth
        self.onMonthChanged = onMonthChanged
    }

    // Legacy initializer:
    // MonthPickerRow(months, defaultMonth, onChange)
    init(
        _ months: [String],
        _ defaultMonth: String,
        _ onMonthChanged: @escaping (String) -> Void
    ) {
        self.title = "Month"
        self.months = months
        self.defaultMonth = defaultMonth
        self.onMonthChanged = onMonthChanged
        self._selectedMonth = .constant(defaultMonth)
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Menu {
                ForEach(months, id: \.self) { month in
                    Button {
                        selectedMonth = month
                        onMonthChanged(month)
                    } label: {
                        if month == selectedMonth {
                            Label(prettyMonth(month), systemImage: "checkmark")
                        } else {
                            Text(prettyMonth(month))
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(prettyMonth(selectedMonth))
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.primary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(AppTheme.primary.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button {
                selectedMonth = defaultMonth
                onMonthChanged(defaultMonth)
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color.secondary.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reset to current month")
        }
        .animation(.easeInOut(duration: 0.2), value: selectedMonth)
    }
}

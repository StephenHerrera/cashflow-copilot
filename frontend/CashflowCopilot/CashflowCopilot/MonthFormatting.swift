import Foundation

func currentMonthString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM"
    return formatter.string(from: Date())
}

func lastNMonthsOptions(_ n: Int = 12) -> [String] {
    var result: [String] = []
    let cal = Calendar.current
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM"

    for i in 0..<n {
        if let date = cal.date(byAdding: .month, value: -i, to: Date()) {
            result.append(formatter.string(from: date))
        }
    }
    return result
}

/// Converts "YYYY-MM" → "February 2026"
func UIMonth(_ yyyyMM: String) -> String {
    let parts = yyyyMM.split(separator: "-")
    guard parts.count == 2,
          let year = Int(parts[0]),
          let month = Int(parts[1]),
          (1...12).contains(month)
    else { return yyyyMM }

    let monthName = DateFormatter().monthSymbols[month - 1]
    return "\(monthName) \(year)"
}

/// Compatibility helper (older code sometimes used prettyMonth)
func prettyMonth(_ yyyyMM: String) -> String {
    UIMonth(yyyyMM)
}

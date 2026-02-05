//
//  MonthFormatting.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/5/26.
//

import Foundation

/// Converts "YYYY-MM" into a friendly label like "02 • February 2026"
func UIMonth(_ yyyyMM: String) -> String {
    let parts = yyyyMM.split(separator: "-")
    guard parts.count == 2 else { return yyyyMM }

    let year = String(parts[0])
    let monthNum = String(parts[1])

    // Convert month number to month name
    let monthName: String = {
        switch monthNum {
        case "01": return "January"
        case "02": return "February"
        case "03": return "March"
        case "04": return "April"
        case "05": return "May"
        case "06": return "June"
        case "07": return "July"
        case "08": return "August"
        case "09": return "September"
        case "10": return "October"
        case "11": return "November"
        case "12": return "December"
        default: return monthNum
        }
    }()

    return "\(monthName) - \(year)"
}

func lastNMonthsOptions(_ n: Int = 12) -> [String] {
    var result: [String] = []
    let calendar = Calendar.current

    for i in 0..<n {
        if let date = calendar.date(byAdding: .month, value: -i, to: Date()) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            result.append(formatter.string(from: date))
        }
    }
    return result
}

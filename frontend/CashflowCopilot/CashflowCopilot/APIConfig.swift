//
//  APIConfig.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/4/26.
//

import Foundation

enum APIConfig {
    // Start with simulator. We'll switch to iPhone later.
    static let simulatorBaseURL = "http://127.0.0.1:8000"

    // Later you'll replace YOUR_MAC_IP_HERE with your Mac's IP for physical iPhone.
    static let iphoneBaseURL = "http://172.24.30.59"

    // For now, keep this as simulatorBaseURL
    static var baseURL: String = simulatorBaseURL
}

import Foundation

enum APIConfig {
    // ✅ Simulator can hit localhost
    static let simulatorBaseURL = "http://127.0.0.1:8000"

    // ✅ Physical iPhone must hit your Mac’s LAN IP + port
    // Example: http://192.168.1.50:8000
    static let iphoneBaseURL = "http://172.24.30.59:8000"

    // Switch when needed:
    static var baseURL: String = simulatorBaseURL
}

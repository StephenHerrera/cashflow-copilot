import Foundation

struct HealthResponse: Codable {
    let status: String
}

struct CreateTransactionRequest: Codable {
    let amount: Double
    let description: String
    let category: String?
    let date: String // "YYYY-MM-DD"
}

struct UpdateTransactionRequest: Codable {
    let amount: Double
    let description: String
    let category: String
    let date: String // "YYYY-MM-DD"
}

struct UpdateBudgetRequest: Codable {
    let month: String
    let category: String
    let limit_amount: Double
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .requestFailed(let code):
            return "Request failed with status code \(code)."
        case .decodingFailed:
            return "Failed to decode server response."
        }
    }
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    // MARK: - Health

    func getHealth() async throws -> HealthResponse {
        guard let url = URL(string: "\(APIConfig.baseURL)/health") else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)
        guard let decoded = try? JSONDecoder().decode(HealthResponse.self, from: data) else {
            throw APIError.decodingFailed
        }
        return decoded
    }

    // MARK: - Transactions

    func getTransactions() async throws -> [TransactionItem] {
        guard let url = URL(string: "\(APIConfig.baseURL)/transactions") else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)

        guard let decoded = try? JSONDecoder().decode([TransactionItem].self, from: data) else {
            throw APIError.decodingFailed
        }
        return decoded
    }

    func createTransaction(request: CreateTransactionRequest) async throws {
        guard let url = URL(string: "\(APIConfig.baseURL)/transactions") else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(request)

        let (_, response) = try await URLSession.shared.data(for: req)
        try validate(response)
    }

    func deleteTransaction(id: Int) async throws {
        guard let url = URL(string: "\(APIConfig.baseURL)/transactions/\(id)") else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: req)
        try validate(response)
    }

    func updateTransaction(id: Int, request: UpdateTransactionRequest) async throws {
        guard let url = URL(string: "\(APIConfig.baseURL)/transactions/\(id)") else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(request)

        let (_, response) = try await URLSession.shared.data(for: req)
        try validate(response)
    }

    // MARK: - Summary

    func getSummary(month: String) async throws -> SummaryResponse {
        guard let url = URL(string: "\(APIConfig.baseURL)/summary?month=\(month)") else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)

        guard let decoded = try? JSONDecoder().decode(SummaryResponse.self, from: data) else {
            throw APIError.decodingFailed
        }
        return decoded
    }

    // MARK: - Trend

    func getTrend(months: Int? = nil) async throws -> [TrendRow] {
        var urlString = "\(APIConfig.baseURL)/trend"
        if let months { urlString += "?months=\(months)" }

        guard let url = URL(string: urlString) else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)

        guard let decoded = try? JSONDecoder().decode([TrendRow].self, from: data) else {
            throw APIError.decodingFailed
        }
        return decoded
    }

    // MARK: - Budgets

    func getBudgets(month: String? = nil) async throws -> [BudgetItem] {
        var urlString = "\(APIConfig.baseURL)/budgets"
        if let month, !month.isEmpty { urlString += "?month=\(month)" }

        guard let url = URL(string: urlString) else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)

        guard let decoded = try? JSONDecoder().decode([BudgetItem].self, from: data) else {
            throw APIError.decodingFailed
        }
        return decoded
    }

    func createOrUpdateBudget(request: CreateBudgetRequest) async throws {
        guard let url = URL(string: "\(APIConfig.baseURL)/budgets") else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(request)

        let (_, response) = try await URLSession.shared.data(for: req)
        try validate(response)
    }

    func deleteBudget(id: Int) async throws {
        guard let url = URL(string: "\(APIConfig.baseURL)/budgets/\(id)") else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: req)
        try validate(response)
    }

    func updateBudget(id: Int, request: UpdateBudgetRequest) async throws {
        guard let url = URL(string: "\(APIConfig.baseURL)/budgets/\(id)") else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(request)

        let (_, response) = try await URLSession.shared.data(for: req)
        try validate(response)
    }

    // MARK: - Helpers

    private func validate(_ response: URLResponse) throws {
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.requestFailed(http.statusCode)
        }
    }
}

//
//  APIClient.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/4/26.
//

import Foundation

// This matches your FastAPI /health response: {"status": "ok"}
struct HealthResponse: Codable {
    let status: String
}

struct CreateTransactionRequest: Codable {
    let amount: Double
    let description: String
    let date: String
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

struct UpdateTransactionRequest: Codable {
    let amount: Double
    let description: String
    let category: String
    let date: String // "YYYY-MM-DD"
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    func getHealth() async throws -> HealthResponse {
        guard let url = URL(string: "\(APIConfig.baseURL)/health") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.requestFailed(http.statusCode)
        }

        guard let decoded = try? JSONDecoder().decode(HealthResponse.self, from: data) else {
            throw APIError.decodingFailed
        }

        return decoded
    }
    
    func getTransactions() async throws -> [TransactionItem] {
        guard let url = URL(string: "\(APIConfig.baseURL)/transactions") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.requestFailed(http.statusCode)
        }

        guard let decoded = try? JSONDecoder().decode([TransactionItem].self, from: data) else {
            throw APIError.decodingFailed
        }

        return decoded
    }
    
    func createTransaction(request: CreateTransactionRequest) async throws {
        guard let url = URL(string: "\(APIConfig.baseURL)/transactions") else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (_, response) = try await URLSession.shared.data(for: urlRequest)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.requestFailed(http.statusCode)
        }
    }
    
    func getSummary(month: String) async throws -> SummaryResponse {
        guard let url = URL(string: "\(APIConfig.baseURL)/summary?month=\(month)") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.requestFailed(http.statusCode)
        }

        guard let decoded = try? JSONDecoder().decode(SummaryResponse.self, from: data) else {
            throw APIError.decodingFailed
        }

        return decoded
    }
    
    func getTrend(months: Int? = nil) async throws -> [TrendRow] {
        var urlString = "\(APIConfig.baseURL)/trend"
        if let months {
            urlString += "?months=\(months)"
        }

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.requestFailed(http.statusCode)
        }

        guard let decoded = try? JSONDecoder().decode([TrendRow].self, from: data) else {
            throw APIError.decodingFailed
        }

        return decoded
    }
    
    func getBudgets(month: String? = nil) async throws -> [BudgetItem] {
        var urlString = "\(APIConfig.baseURL)/budgets"
        if let month, !month.isEmpty {
            urlString += "?month=\(month)"
        }

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.requestFailed(http.statusCode)
        }

        guard let decoded = try? JSONDecoder().decode([BudgetItem].self, from: data) else {
            throw APIError.decodingFailed
        }

        return decoded
    }

    func createOrUpdateBudget(request: CreateBudgetRequest) async throws {
        guard let url = URL(string: "\(APIConfig.baseURL)/budgets") else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (_, response) = try await URLSession.shared.data(for: urlRequest)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.requestFailed(http.statusCode)
        }
    }
    
    func deleteTransaction(id: Int) async throws {
        guard let url = URL(string: "\(APIConfig.baseURL)/transactions/\(id)") else {
            throw APIError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: req)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.requestFailed(http.statusCode)
        }
    }

    func updateTransaction(id: Int, request: UpdateTransactionRequest) async throws {
        guard let url = URL(string: "\(APIConfig.baseURL)/transactions/\(id)") else {
            throw APIError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(request)

        let (_, response) = try await URLSession.shared.data(for: req)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.requestFailed(http.statusCode)
        }
    }
    
}

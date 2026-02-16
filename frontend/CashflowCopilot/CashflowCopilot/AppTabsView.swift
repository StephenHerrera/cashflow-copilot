//
//  AppTabsView.swift
//  CashflowCopilot
//
//  Created by Stephen Herrera on 2/5/26.
//
import SwiftUI

struct AppTabsView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            TransactionsView()
                .tabItem { Label("Transactions", systemImage: "list.bullet") }

            SummaryView()
                .tabItem { Label("Summary", systemImage: "chart.pie") }

            BudgetsView()
                .tabItem { Label("Budgets", systemImage: "target") }

            TrendView()
                .tabItem { Label("Trend", systemImage: "chart.line.uptrend.xyaxis") }
        }
    }
}

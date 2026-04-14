import SwiftUI

struct AppTabsView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }

            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "chart.pie")
                }

            BudgetsView()
                .tabItem {
                    Label("Budgets", systemImage: "target")
                }
        }
    }
}

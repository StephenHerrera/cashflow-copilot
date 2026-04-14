import SwiftUI

@main
struct CashflowCopilotApp: App {
    var body: some Scene {
        WindowGroup {
            AppTabsView()
                .tint(AppTheme.primary)
        }
    }
}

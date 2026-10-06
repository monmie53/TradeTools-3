import SwiftUI

@main
struct TradeToolsApp: App {
    @StateObject private var journal = JournalStore()
    var body: some Scene {
        WindowGroup {
            TabView {
                PositionSizeView().tabItem { Label("Size", systemImage: "scalemass") }
                RiskRewardView().tabItem { Label("R:R", systemImage: "arrow.up.right") }
                KillzoneView().tabItem { Label("Sessions", systemImage: "clock") }
                JournalView().tabItem { Label("Journal", systemImage: "book") }
            }
            .environmentObject(journal)
            .tint(.gold)
            .preferredColorScheme(.dark)
        }
    }
}

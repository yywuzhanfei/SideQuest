import SwiftUI

@main
struct SideQuestApp: App {
    @StateObject private var store = ActivityStore()

    var body: some Scene {
        MenuBarExtra("SideQuest", systemImage: "sparkles") {
            MenuContentView(store: store)
        }
        .menuBarExtraStyle(.window)
    }
}

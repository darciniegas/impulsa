import SwiftUI

@main
struct impulsaApp: App {
    @StateObject private var repo = Repositorio()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(repo)
                .tint(Color.impPrimary)
        }
    }
}

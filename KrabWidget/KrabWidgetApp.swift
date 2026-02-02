import SwiftUI

@main
struct KrabWidgetApp: App {
    @StateObject private var connection = OpenClawConnection.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connection)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

import SwiftUI

@main
struct AnimageUpscaleApp: App {
    init() {
        DefaultSettings.loadSettings()
    }
    var body: some Scene {
        WindowGroup {
            MainWindow(QueueStore: QueueControl())
        }
    }
}

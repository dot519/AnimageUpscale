import SwiftUI

@main
struct AnimageUpscaleApp: App {
    init() {
        DefaultSettings.loadSettings()
    }
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainWindow(QueueStore: QueueControl())
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

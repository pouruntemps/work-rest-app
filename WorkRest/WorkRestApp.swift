import SwiftUI

@main
struct WorkRestApp: App {
    // Hide the Dock icon:
//    init() {
//        NSApp.setActivationPolicy(.accessory)
//    }
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

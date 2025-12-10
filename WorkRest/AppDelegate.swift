import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var timerModel = TimerModel()
    var multiTimerModel = MultiTimerModel()
    
    var selectedTab: TimerTab = .single
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the Dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Request notification permissions
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
        
        // Setup the status item (menu bar icon)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = timerModel.menuBarTitle
        
        // Setup popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 220, height: 280)
        popover.behavior = .transient
        updatePopoverContent()
        
        // Listen to single timer updates
        timerModel.onTick = { [weak self] in
            self?.updateStatusItem()
        }
        timerModel.onTimerEnd = { [weak self] in
            self?.showNotification(title: "Time's up!", message: "Work / Rest timer finished.")
            self?.updateStatusItem()
        }
        
        // Listen to multi timer updates
        multiTimerModel.onTick = { [weak self] in
            self?.updateStatusItem()
        }
        multiTimerModel.onTimerEnd = { [weak self] index in
            guard let self = self else { return }
            let message = self.multiTimerModel.endMessages[index]
            self.showNotification(title: "WorkRest", message: message)
            self.updateStatusItem()
        }
        multiTimerModel.onAllTimersComplete = { [weak self] in
            self?.updateStatusItem()
        }
        
        // Setup click action
        if let button = statusItem.button {
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }
    
    func updateStatusItem() {
        if let button = statusItem.button {
            if selectedTab == .single {
                button.title = timerModel.menuBarTitle
            } else {
                button.title = multiTimerModel.menuBarTitle
            }
        }
    }
    
    func updatePopoverContent() {
        popover.contentViewController = NSHostingController(rootView: 
            PopoverView(
                model: timerModel,
                multiModel: multiTimerModel,
                initialTab: selectedTab,
                onTabChange: { newTab in
                    self.selectedTab = newTab
                    self.updateStatusItem()
                },
                onUpdate: {
                    self.updateStatusItem()
                }
            )
        )
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                updatePopoverContent()
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func showNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to deliver notification: \(error)")
            }
        }
    }
    
    // Show notifications even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

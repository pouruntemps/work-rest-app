import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var timerModel = TimerModel()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
        
        // Setup the status item (menu bar icon)
        // Hide the Dock icon here, where NSApp is ready!
            NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = timerModel.menuBarTitle // This ensures .button is not nil!
//        updateStatusItem()
        
        // Setup popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 220, height: 120)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: PopoverView(model: timerModel, onUpdate: {
            self.updateStatusItem()
        }))
        
        // Listen to timer updates
        timerModel.onTick = { [weak self] in
            self?.updateStatusItem()
        }
        timerModel.onTimerEnd = { [weak self] in
            self?.showNotification()
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
            button.title = timerModel.menuBarTitle
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.contentViewController = NSHostingController(rootView: PopoverView(model: timerModel, onUpdate: {
                    self.updateStatusItem()
                }))
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func showNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time's up. Time to rest."
        content.body = "Work / Rest timer finished."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "timer-complete", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error)")
            }
        }
    }
}

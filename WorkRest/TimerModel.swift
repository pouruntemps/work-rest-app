import Foundation

class TimerModel: ObservableObject {
    @Published var totalSeconds: Int = 1800 // Default 30 min
    @Published var remainingSeconds: Int = 1800
    @Published var isRunning: Bool = false
    var timer: Timer?
    var lastSetSeconds: Int = 1800

    var onTick: (() -> Void)?
    var onTimerEnd: (() -> Void)?
    
    var menuBarTitle: String {
        let icon = isRunning ? "■" : "▶︎"
        return "\(icon) \(timeString(remainingSeconds))"
    }
    
    func timeString(_ sec: Int) -> String {
        let m = sec / 60
        let s = sec % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    func setTime(minutes: Int) {
        totalSeconds = max(1, minutes * 60)
        lastSetSeconds = totalSeconds
        reset()
    }
    
    func start() {
        if remainingSeconds == 0 { remainingSeconds = totalSeconds }
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        onTick?()
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
        onTick?()
    }
    
    func reset() {
        stop()
        remainingSeconds = totalSeconds
        onTick?()
    }
    
    func tick() {
        guard isRunning else { return }
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            onTick?()
        } else {
            stop()
            remainingSeconds = lastSetSeconds
            onTimerEnd?()
        }
    }
}

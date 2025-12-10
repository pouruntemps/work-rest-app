import Foundation

class MultiTimerModel: ObservableObject {
    // Default durations in seconds: 25 min, 10 min, 2 min
    @Published var timerDurations: [Int] = [1500, 600, 120]
    @Published var remainingSeconds: [Int] = [1500, 600, 120]
    @Published var currentTimerIndex: Int = 0
    @Published var isRunning: Bool = false
    
    var timer: Timer?
    
    var onTick: (() -> Void)?
    var onTimerEnd: ((Int) -> Void)? // Passes the index of the timer that just ended
    var onAllTimersComplete: (() -> Void)?
    
    let timerLabels = ["Work", "Stand", "Walk"]
    let endMessages = ["Time to stand up", "Time to walk", "Next session?"]
    
    var menuBarTitle: String {
        let icon = isRunning ? "■" : "▶︎"
        let currentRemaining = remainingSeconds[currentTimerIndex]
        let label = timerLabels[currentTimerIndex]
        return "\(icon) \(label): \(timeString(currentRemaining))"
    }
    
    func timeString(_ sec: Int) -> String {
        let m = sec / 60
        let s = sec % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    func setTime(index: Int, minutes: Int) {
        let seconds = max(1, minutes * 60)
        timerDurations[index] = seconds
        remainingSeconds[index] = seconds
    }
    
    func start() {
        if remainingSeconds[currentTimerIndex] == 0 {
            remainingSeconds[currentTimerIndex] = timerDurations[currentTimerIndex]
        }
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
        currentTimerIndex = 0
        for i in 0..<timerDurations.count {
            remainingSeconds[i] = timerDurations[i]
        }
        onTick?()
    }
    
    func tick() {
        guard isRunning else { return }
        
        if remainingSeconds[currentTimerIndex] > 0 {
            remainingSeconds[currentTimerIndex] -= 1
            onTick?()
        } else {
            // Current timer finished
            let finishedIndex = currentTimerIndex
            onTimerEnd?(finishedIndex)
            
            // Move to next timer or reset all
            if currentTimerIndex < timerDurations.count - 1 {
                currentTimerIndex += 1
                remainingSeconds[currentTimerIndex] = timerDurations[currentTimerIndex]
                onTick?()
                // Continue running - don't stop
            } else {
                // All timers complete - reset everything
                stop()
                currentTimerIndex = 0
                for i in 0..<timerDurations.count {
                    remainingSeconds[i] = timerDurations[i]
                }
                onAllTimersComplete?()
                onTick?()
            }
        }
    }
}


import SwiftUI

enum TimerTab: String, CaseIterable {
    case single = "Single"
    case multi = "Multi"
}

struct PopoverView: View {
    @ObservedObject var model: TimerModel
    @ObservedObject var multiModel: MultiTimerModel
    var initialTab: TimerTab
    var onTabChange: (TimerTab) -> Void
    var onUpdate: () -> Void
    
    @State private var selectedTab: TimerTab = .single
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab picker
            Picker("", selection: $selectedTab) {
                ForEach(TimerTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .onChange(of: selectedTab) { _, newTab in
                onTabChange(newTab)
            }
            
            // Content based on selected tab
            if selectedTab == .single {
                SingleTimerView(model: model, onUpdate: onUpdate)
            } else {
                MultiTimerView(model: multiModel, onUpdate: onUpdate)
            }
        }
        .frame(width: 220)
        .onAppear {
            selectedTab = initialTab
        }
    }
}

// MARK: - Single Timer View
struct SingleTimerView: View {
    @ObservedObject var model: TimerModel
    @State private var minutesText: String = ""
    var onUpdate: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Set minutes:")
                TextField("", text: Binding(
                    get: {
                        minutesText.isEmpty ? String(model.totalSeconds / 60) : minutesText
                    },
                    set: { minutesText = $0 }
                ))
                .frame(width: 40)
                .multilineTextAlignment(.center)
                .onSubmit {
                    updateMinutes()
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Button(action: {
                model.isRunning ? model.stop() : model.start()
                onUpdate()
            }) {
                HStack {
                    Image(systemName: model.isRunning ? "stop.fill" : "play.fill")
                    Text(model.isRunning ? "Stop" : "Start")
                }
            }
            .buttonStyle(.bordered)
            .padding(.top, 4)
            
            Text(model.timeString(model.remainingSeconds))
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .padding(.top, 6)
        }
        .padding(16)
        .onAppear {
            minutesText = String(model.totalSeconds / 60)
        }
    }
    
    func updateMinutes() {
        if let m = Int(minutesText), m > 0 {
            model.setTime(minutes: m)
            onUpdate()
        }
    }
}

// MARK: - Multi Timer View
struct MultiTimerView: View {
    @ObservedObject var model: MultiTimerModel
    @State private var timer1Text: String = ""
    @State private var timer2Text: String = ""
    @State private var timer3Text: String = ""
    var onUpdate: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            // Timer inputs
            VStack(spacing: 6) {
                timerRow(label: "Work:", text: $timer1Text, index: 0, defaultMinutes: model.timerDurations[0] / 60)
                timerRow(label: "Stand:", text: $timer2Text, index: 1, defaultMinutes: model.timerDurations[1] / 60)
                timerRow(label: "Walk:", text: $timer3Text, index: 2, defaultMinutes: model.timerDurations[2] / 60)
            }
            
            Button(action: {
                model.isRunning ? model.stop() : model.start()
                onUpdate()
            }) {
                HStack {
                    Image(systemName: model.isRunning ? "stop.fill" : "play.fill")
                    Text(model.isRunning ? "Stop" : "Start")
                }
            }
            .buttonStyle(.bordered)
            .padding(.top, 4)
            
            // Current timer display
            VStack(spacing: 2) {
                Text(model.timerLabels[model.currentTimerIndex])
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Text(model.timeString(model.remainingSeconds[model.currentTimerIndex]))
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
            }
            .padding(.top, 4)
            
            // Progress indicators
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index == model.currentTimerIndex ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 4)
        }
        .padding(16)
        .onAppear {
            timer1Text = String(model.timerDurations[0] / 60)
            timer2Text = String(model.timerDurations[1] / 60)
            timer3Text = String(model.timerDurations[2] / 60)
        }
    }
    
    func timerRow(label: String, text: Binding<String>, index: Int, defaultMinutes: Int) -> some View {
        HStack {
            Text(label)
                .frame(width: 50, alignment: .leading)
            TextField("", text: Binding(
                get: {
                    text.wrappedValue.isEmpty ? String(defaultMinutes) : text.wrappedValue
                },
                set: { text.wrappedValue = $0 }
            ))
            .frame(width: 40)
            .multilineTextAlignment(.center)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onSubmit {
                setAllTimers()
            }
            Text("min")
                .foregroundColor(.secondary)
        }
    }
    
    func setAllTimers() {
        if let m1 = Int(timer1Text), m1 > 0 {
            model.setTime(index: 0, minutes: m1)
        }
        if let m2 = Int(timer2Text), m2 > 0 {
            model.setTime(index: 1, minutes: m2)
        }
        if let m3 = Int(timer3Text), m3 > 0 {
            model.setTime(index: 2, minutes: m3)
        }
        model.reset()
        onUpdate()
    }
}

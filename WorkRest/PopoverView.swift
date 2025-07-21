import SwiftUI

struct PopoverView: View {
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
            
            HStack(spacing: 18) {
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
                
                Button(action: {
                    updateMinutes()
                }) {
                    Text("Set")
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 4)
            
            Text(model.timeString(model.remainingSeconds))
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .padding(.top, 6)
        }
        .padding(16)
        .frame(width: 200)
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

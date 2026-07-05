import SwiftUI

struct LevelSettingsView: View {
    @Binding var maxTime: TimeInterval
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List([30.0, 60.0, 90.0], id: \.self) { time in
                Button { maxTime = time; dismiss() } label: {
                    HStack {
                        Text("\(Int(time)) Seconds")
                        Spacer()
                        if maxTime == time { Image(systemName: "checkmark") }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

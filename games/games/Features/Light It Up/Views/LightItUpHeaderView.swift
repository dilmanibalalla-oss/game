import SwiftUI

struct LightItUpHeaderView: View {
    let levelNumber: Int
    let round: Int
    let elapsedTime: TimeInterval
    let score: Int
    let lives: Int
    let onSettingsTap: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("L: \(levelNumber) | R: \(round) | T: \(Int(elapsedTime))s")
                    .foregroundColor(.white)
                    .bold()
                Text("Score: \(score)")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
            }
            .padding(.leading, 20) // Shifted to the right
            Spacer()
            Button("Lives") { onSettingsTap() }
                .foregroundColor(.white)
                .bold()
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                        .bold()
                }
            }
        }
        .padding()
    }
}

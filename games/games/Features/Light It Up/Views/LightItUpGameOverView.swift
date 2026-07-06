import SwiftUI

struct LightItUpGameOverView: View {
    let score: Int
    let onPlayAgain: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            GameOverHeader(title: "Game Over")
            Text("Final Score: \(score)").font(.title)
            GameButton(title: "Play Again", accentColor: AppColors.lightItUp, action: onPlayAgain)
        }
    }
}

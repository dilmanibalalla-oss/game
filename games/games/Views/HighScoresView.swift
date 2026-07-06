import SwiftUI

struct HighScoresView: View {
    @AppStorage(HighScoreKeys.tapFrenzy) private var tapFrenzyHighScore = 0
    @AppStorage(HighScoreKeys.lightItUp) private var lightItUpHighScore = 0
    @AppStorage(HighScoreKeys.quiz) private var quizHighScore = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient.skyBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("High Scores")
                    .font(AppFonts.pageTitle)
                    .foregroundColor(.white)
                    .padding(.top, 20)

                VStack(spacing: 15) {
                    HighScoreRow(title: "Tap Frenzy", icon: "hand.tap.fill", color: .blue, score: tapFrenzyHighScore, panelTint: AppColors.panelTint, lavenderColor: AppColors.skyMid)
                    HighScoreRow(title: "Light It Up", icon: "lightbulb.fill", color: .purple, score: lightItUpHighScore, panelTint: AppColors.panelTint, lavenderColor: AppColors.skyMid)
                    HighScoreRow(title: "Quiz Rush", icon: "questionmark.circle.fill", color: .orange, score: quizHighScore, panelTint: AppColors.panelTint, lavenderColor: AppColors.skyMid)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.skyMid)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                }
                .padding()
            }
        }
    }
}

private struct HighScoreRow: View {
    let title: String
    let icon: String
    let color: Color
    let score: Int
    let panelTint: Color
    let lavenderColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(lavenderColor) // Updated to Lavender
                .frame(width: 50)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(AppFonts.rowTitle)
                Text("Best score")
                    .font(.caption)
                    .opacity(0.6)
            }
            
            Spacer()
            
            Text("\(score)")
                .font(AppFonts.scoreValue)
                .foregroundColor(color)
        }
        .padding()
        .background(panelTint)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

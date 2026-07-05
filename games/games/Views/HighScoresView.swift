import SwiftUI

struct HighScoresView: View {
    @AppStorage(HighScoreKeys.tapFrenzy) private var tapFrenzyHighScore = 0
    @AppStorage(HighScoreKeys.lightItUp) private var lightItUpHighScore = 0
    @AppStorage(HighScoreKeys.quiz) private var quizHighScore = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pink.opacity(0.2).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    HighScoreRow(title: "Tap Frenzy", icon: "hand.tap.fill", color: .blue, score: tapFrenzyHighScore)
                    HighScoreRow(title: "Light It Up", icon: "lightbulb.fill", color: .purple, score: lightItUpHighScore)
                    HighScoreRow(title: "Quiz Rush", icon: "questionmark.circle.fill", color: .orange, score: quizHighScore)
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("High Scores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct HighScoreRow: View {
    let title: String
    let icon: String
    let color: Color
    let score: Int
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2.bold())
                Text("Best score")
                    .font(.caption)
                    .opacity(0.8)
            }
            Spacer()
            Text("\(score)")
                .font(.title.bold())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.black, lineWidth: 2))
    }
}

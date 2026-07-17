import SwiftUI

struct HighScoresView: View {
    @AppStorage(HighScoreKeys.tapFrenzy) private var tapFrenzyHighScore = 0
    @AppStorage(HighScoreKeys.lightItUp) private var lightItUpHighScore = 0
    @AppStorage(HighScoreKeys.quiz) private var quizHighScore = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Text("Tap Frenzy")
                        .font(.headline)
                    Spacer()
                    Text("\(tapFrenzyHighScore) pts")
                        .bold()
                }
                HStack {
                    Text("Light It Up")
                        .font(.headline)
                    Spacer()
                    Text("\(lightItUpHighScore) pts")
                        .bold()
                }
                HStack {
                    Text("Quiz Rush")
                        .font(.headline)
                    Spacer()
                    Text("\(quizHighScore) pts")
                        .bold()
                }
            }
            .navigationTitle("High Scores")
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

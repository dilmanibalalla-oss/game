import SwiftUI

struct QuizView: View {
    @StateObject var viewModels = QuizViewModel()
    @State private var hasSelectedDifficulty = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pink.opacity(0.2).ignoresSafeArea()
                
                if !hasSelectedDifficulty {
                    // Difficulty Selection Screen
                    VStack(spacing: 20) {
                        Text("Select Difficulty").font(.largeTitle).bold()
                        ForEach(Difficulty.allCases) { diff in
                            Button(action: {
                                viewModels.selectedDifficulty = diff
                                hasSelectedDifficulty = true
                            }) {
                                Text(diff.rawValue.capitalized)
                                    .font(.title2)
                                    .frame(width: 200)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .shadow(radius: 3)
                            }
                        }
                    }
                } else {
                    // Quiz Gameplay Screen
                    Group {
                        switch viewModels.state {
                        case .loading:
                            ProgressView("Loading your challenge...")
                                .task { await viewModels.load() }
                            
                        case .failed:
                            VStack(spacing: 20) {
                                Text("Network Error").font(.title).bold()
                                Button("Retry") { Task { await viewModels.load() } }
                                    .buttonStyle(.borderedProminent)
                            }
                            
                        case .finished:
                            VStack(spacing: 20) {
                                Text("Quiz Finished!").font(.largeTitle).bold()
                                Text("Final Score: \(viewModels.score)").font(.title)
                                Button("Restart") { hasSelectedDifficulty = false }
                            }
                            
                        case .loaded:
                            if viewModels.questions.indices.contains(viewModels.currentIndex) {
                                let q = viewModels.questions[viewModels.currentIndex]
                                VStack(spacing: 30) {
                                    HStack {
                                        Text("Score: \(viewModels.score)").font(.headline)
                                        Spacer()
                                        Text("Time: \(viewModels.timeLeft)s")
                                            .foregroundColor(viewModels.timeLeft < 5 ? .red : .blue)
                                    }
                                    .padding(.horizontal)
                                    
                                    Text(q.question)
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .multilineTextAlignment(.center)
                                        .padding()
                                        .background(Color.white.opacity(0.5))
                                        .cornerRadius(15)
                                        .padding(.horizontal)
                                    
                                    VStack(spacing: 15) {
                                        ForEach(q.allAnswers, id: \.self) { answer in
                                            Button(action: {
                                                withAnimation { viewModels.submitAnswer(answer) }
                                            }) {
                                                Text(answer)
                                                    .frame(maxWidth: .infinity)
                                                    .padding()
                                                    .background(Color.white)
                                                    .cornerRadius(15)
                                                    .shadow(radius: 3)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Quiz Rush")
        }
    }
}

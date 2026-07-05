import SwiftUI

struct QuizView: View {
    @StateObject var viewModels = QuizViewModel()
    @State private var hasSelectedDifficulty = false
    @State private var selectedCategory: QuizCategory? = nil
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var flashOpacity: Double = 0.0
    @State private var shakeOffset: CGFloat = 0.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pink.opacity(0.2).ignoresSafeArea()
                
                if !hasSelectedDifficulty {
                    VStack(spacing: 25) {
                        Text("Quiz Settings")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.pink)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Select Category")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Picker("Category", selection: $selectedCategory) {
                                Text("Any Category").tag(nil as QuizCategory?)
                                ForEach(QuizCategory.all) { cat in
                                    Text(cat.name).tag(cat as QuizCategory?)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 3)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Select Difficulty")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Picker("Difficulty", selection: $selectedDifficulty) {
                                ForEach(Difficulty.allCases) { diff in
                                    Text(diff.rawValue.capitalized).tag(diff)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 3)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            viewModels.selectedCategory = selectedCategory
                            viewModels.selectedDifficulty = selectedDifficulty
                            hasSelectedDifficulty = true
                        }) {
                            Text("Start Quiz")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.pink)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    .padding()
                } else {
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
                                ShareLink(item: "I just scored \(viewModels.score) on Quiz Rush, beat that!")
                                Button("Restart") { hasSelectedDifficulty = false }
                            }
                            
                        case .loaded:
                            if viewModels.questions.indices.contains(viewModels.currentIndex) {
                                let q = viewModels.questions[viewModels.currentIndex]
                                VStack(spacing: 20) {
                                    // Header metrics
                                    HStack {
                                        Text("Score: \(viewModels.score)").font(.headline)
                                        Spacer()
                                        Text("Time: \(viewModels.timeLeft)s")
                                            .foregroundColor(viewModels.timeLeft < 5 ? .red : .blue)
                                    }
                                    .padding(.horizontal)
                                    
                                    // 3 of 10 Progress Bar and Streak
                                    VStack(spacing: 8) {
                                        HStack {
                                            Text("Question \(viewModels.currentIndex + 1) of \(viewModels.questions.count)")
                                                .font(.subheadline.bold())
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("Streak: \(viewModels.streak)")
                                                .font(.subheadline.bold())
                                                .foregroundColor(.orange)
                                        }
                                        
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                Capsule()
                                                    .fill(Color.black.opacity(0.1))
                                                    .frame(height: 8)
                                                
                                                Capsule()
                                                    .fill(Color.pink)
                                                    .frame(width: geometry.size.width * CGFloat(viewModels.currentIndex + 1) / CGFloat(max(1, viewModels.questions.count)), height: 8)
                                                    .animation(.spring(), value: viewModels.currentIndex)
                                            }
                                        }
                                        .frame(height: 8)
                                    }
                                    .padding(.horizontal)
                                    
                                    // Question Card (with shake offset)
                                    Text(q.question)
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .multilineTextAlignment(.center)
                                        .padding()
                                        .background(Color.white.opacity(0.5))
                                        .cornerRadius(15)
                                        .padding(.horizontal)
                                        .offset(x: shakeOffset)
                                    
                                    VStack(spacing: 15) {
                                        ForEach(q.allAnswers, id: \.self) { answer in
                                            Button(action: {
                                                let isCorrect = viewModels.submitAnswer(answer)
                                                if isCorrect {
                                                    withAnimation(.easeIn(duration: 0.1)) {
                                                        flashOpacity = 0.5
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        withAnimation(.easeOut(duration: 0.2)) {
                                                            flashOpacity = 0.0
                                                        }
                                                    }
                                                } else {
                                                    withAnimation(.default) {
                                                        shakeOffset = 15
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        withAnimation(.default) {
                                                            shakeOffset = -15
                                                        }
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                            withAnimation(.default) {
                                                                shakeOffset = 0
                                                            }
                                                        }
                                                    }
                                                }
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
                
                // Color flash overlay for correct answers
                Color.green.opacity(flashOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            .navigationTitle("Quiz Rush")
        }
    }
}

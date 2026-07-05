import Foundation
import SwiftUI
import Combine

enum QuizState { case loading, loaded, failed, finished }

class QuizViewModel: ObservableObject {
    @Published var state: QuizState = .loading
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var highScore = UserDefaults.standard.integer(forKey: "QuizHighScore")
    @Published var timeLeft = 15
    
    @Published var selectedDifficulty: Difficulty?
    
    let questionCount = 10
    private var timer: AnyCancellable?
    private let service = QuizService()
    
    // Added SessionManager
    private let sessionManager = SessionManager()
    
    @MainActor
    func load() async {
        state = .loading
        score = 0
        streak = 0
        currentIndex = 0
        
        do {
            self.questions = try await service.fetchQuestions(difficulty: selectedDifficulty?.rawValue)
            self.questions = Array(self.questions.prefix(questionCount))
            self.state = .loaded
            startQuestionTimer()
        } catch {
            self.state = .failed
        }
    }
    
    func startQuestionTimer() {
        timeLeft = 15
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeLeft > 0 {
                    self.timeLeft -= 1
                } else {
                    self.submitAnswer("")
                }
            }
    }
    
    func submitAnswer(_ answer: String) {
        let isCorrect = !answer.isEmpty && answer == questions[currentIndex].correct_answer
        let generator = UINotificationFeedbackGenerator()
        
        if isCorrect {
            generator.notificationOccurred(.success)
            score += 100 + (streak * 25)
            streak += 1
            if score > highScore {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: "QuizHighScore")
            }
        } else {
            generator.notificationOccurred(.error)
            streak = 0
        }
        
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            startQuestionTimer()
        } else {
            timer?.cancel()
            state = .finished
            // Save the session when the quiz finishes
            saveGameSession()
        }
    }
    
    private func saveGameSession() {
        let coords = sessionManager.generateGridCoordinates() // Use the new grid system
        let newSession = GameSession(
            mode: "Quiz - \(selectedDifficulty?.rawValue ?? "General")",
            score: score,
            timestamp: Date(),
            latitude: coords.lat,
            longitude: coords.lon
        )
        sessionManager.save(newSession)
    }
}

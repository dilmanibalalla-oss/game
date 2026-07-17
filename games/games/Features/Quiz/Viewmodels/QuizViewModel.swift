import Foundation
import SwiftUI
import Combine
import CoreLocation

enum QuizState { case loading, loaded, failed, finished }

class QuizViewModel: ObservableObject {
    @Published var state: QuizState = .loading
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var highScore = UserDefaults.standard.integer(forKey: HighScoreKeys.quiz)
    @Published var timeLeft = 15
    
    @Published var selectedDifficulty: Difficulty?
    @Published var selectedCategory: QuizCategory?
    
    let questionCount = 10
    private var timer: AnyCancellable?
    private let service = QuizService()
    
    // Added SessionManager
    private let sessionManager = SessionManager()
    private let locationManager = LocationManager.shared
    
    @MainActor
    func load() async {
        state = .loading
        score = 0
        streak = 0
        currentIndex = 0
        
        do {
            self.questions = try await service.fetchQuestions(
                category: selectedCategory?.id,
                difficulty: selectedDifficulty?.rawValue
            )
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
    
    func submitAnswer(_ answer: String) -> Bool {
        timer?.cancel()
        let isCorrect = !answer.isEmpty && answer == questions[currentIndex].correct_answer
        let generator = UINotificationFeedbackGenerator()
        
        if isCorrect {
            generator.notificationOccurred(.success)
            score += 100 + (streak * 25)
            streak += 1
            if score > highScore {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: HighScoreKeys.quiz)
            }
            SoundManager.shared.playCorrect()
        } else {
            generator.notificationOccurred(.error)
            streak = 0
            SoundManager.shared.playIncorrect()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.currentIndex < self.questions.count - 1 {
                self.currentIndex += 1
                self.startQuestionTimer()
            } else {
                self.state = .finished
                self.saveGameSession()
            }
        }
        
        return isCorrect
    }
    
    private func saveGameSession() {
        let coord = locationManager.lastLocation?.coordinate ?? locationManager.lastKnownCoordinate
        let fallbackLat = 6.9271
        let fallbackLon = 79.8612
        let newSession = GameSession(
            mode: "Quiz",
            score: score,
            timestamp: Date(),
            latitude: coord?.latitude ?? fallbackLat,
            longitude: coord?.longitude ?? fallbackLon
        )
        sessionManager.save(newSession)
    }
}

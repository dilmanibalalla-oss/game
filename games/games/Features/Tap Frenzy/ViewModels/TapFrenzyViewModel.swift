import Foundation
import SwiftUI
import Combine

class TapFrenzyViewModel: ObservableObject {
    @Published var score = 0
    @Published var level = 1
    @Published var timeRemaining: TimeInterval = 10.0
    @Published var isGameOver = false
    @Published var ballScale: CGFloat = 1.0
    private var lastTapTime: Date = Date.distantPast
    private var comboMultiplier = 1
    
    
    @Published var bonusPosition: CGPoint? = nil
    @Published var trapPosition: CGPoint? = nil
    private let sessionManager = SessionManager()
    
    @AppStorage("tapFrenzyHighScore") var highScore = 0
    
    private var timer: AnyCancellable?
    
    init() { startTimer() }
    
    func startTimer() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }
    
    private func tick() {
            guard !isGameOver else { return }
            
            // This keeps the rapid shrinking effect active
            let shrinkRate = 0.005 + (Double(level) * 0.015)
            ballScale = max(0.1, ballScale - shrinkRate)
            
            timeRemaining -= 0.1
            if timeRemaining <= 0 { endGame() }
            
            // Spawn items more frequently at higher levels
            let spawnChance = max(5, 50 - (level * 5))
            if Int.random(in: 1...spawnChance) == 1 {
                spawnItems()
            }
        }
    
    private func spawnItems() {
     
            bonusPosition = CGPoint(x: CGFloat.random(in: 50...300), y: CGFloat.random(in: 100...500))
            // Disappears after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.bonusPosition = nil
            }
            
        
            trapPosition = CGPoint(x: CGFloat.random(in: 50...300), y: CGFloat.random(in: 100...500))
          
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.trapPosition = nil
            }
        }
    
    func processClick(isInsideBall: Bool, isBonus: Bool = false) {
            guard !isGameOver else { return }
            
            let oldLevel = level // Store current level
            
            if isBonus {
                score += 50
                bonusPosition = nil
            } else if isInsideBall {
                let now = Date()
                if now.timeIntervalSince(lastTapTime) <= 0.5 { comboMultiplier += 1 }
                else { comboMultiplier = 1 }
                lastTapTime = now
                score += 1 * comboMultiplier
            } else {
                score = max(0, score - 50)
                comboMultiplier = 1
            }
            
            level = (score / 100) + 1
            
            if level > oldLevel {
                ballScale = 1.0
            }
        }
    
    func endGame() {
        isGameOver = true
        if score > highScore { highScore = score }
        
        let newSession = GameSession(
            mode: "Tap Frenzy",
            score: score,
            timestamp: Date(),
            latitude: 6.9271,
            longitude: 79.8612
        )
        sessionManager.save(newSession)
    }
    
    func resetGame() {
        score = 0; level = 1; timeRemaining = 10.0; ballScale = 1.0; isGameOver = false
    }
}

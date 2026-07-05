import SwiftUI
import Combine

class TapFrenzyViewModel: ObservableObject {
    // Game State
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var comboMultiplier: Int = 1
    @Published var ballPosition: CGPoint = CGPoint(x: 200, y: 400)
    @Published var ballColor: Color = .blue
    @Published var ballScale: CGFloat = 1.0
    @Published var isGameOver: Bool = false
    
    // Internal Logic
    private var lastTapTime: Date = .distantPast
    private var comboTimer: AnyCancellable?
    private var gameTimer: AnyCancellable?
    private var roundTimer: AnyCancellable?
    
    private var roundTimeLeft: Double = 10.0
    private var currentRound: Int = 1
    private var isBonusActive: Bool = false
    
    init() {
        startRound()
    }
    
    func processClick(isInsideBall: Bool) {
        if isInsideBall {
            let now = Date()
            // Check Combo (within 0.5s)
            if now.timeIntervalSince(lastTapTime) < 0.5 {
                comboMultiplier = min(comboMultiplier + 1, 10)
            } else {
                comboMultiplier = 1
            }
            lastTapTime = now
            
            let points = isBonusActive ? 200 : 100
            score += (points * comboMultiplier)
            
            moveBall()
        } else {
            // Penalty for miss
            comboMultiplier = 1
            score = max(0, score - 50)
        }
    }
    
    private func moveBall() {
        let newX = CGFloat.random(in: 50...350)
        let newY = CGFloat.random(in: 100...700)
        withAnimation(.spring()) {
            ballPosition = CGPoint(x: newX, y: newY)
        }
    }
    
    private func startRound() {
        roundTimeLeft = 10.0
        
        // Timer for ball movement and shrinking
        gameTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            self.roundTimeLeft -= 0.1
            self.ballScale = CGFloat(self.roundTimeLeft / 10.0)
            
            if self.roundTimeLeft <= 0 {
                self.endRound()
            }
        }
        
        // Timer for color changes (Random Bonus/Penalty)
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            let isBonus = Bool.random()
            self.ballColor = isBonus ? .green : .gray
            self.isBonusActive = isBonus
            self.moveBall()
        }
    }
    
    private func endRound() {
        gameTimer?.cancel()
        if currentRound < 3 {
            currentRound += 1
            level = currentRound
            startRound()
        } else {
            isGameOver = true
            // Save high score logic would go here
        }
    }
    
    func resetGame() {
        score = 0
        level = 1
        currentRound = 1
        isGameOver = false
        startRound()
    }
}

import SwiftUI
import Combine
import CoreLocation

class TapFrenzyViewModel: ObservableObject {
    
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var comboMultiplier: Int = 1
    @Published var ballPosition: CGPoint = CGPoint(x: 200, y: 400)
    @Published var ballColor: Color = .blue
    @Published var ballScale: CGFloat = 1.0
    @Published var isGameOver: Bool = false
    @Published var showDoubleDash = false
    @Published var doubleDashPosition: CGPoint = CGPoint(x: 200, y: 300)
    
    
    private var lastTapTime: Date = .distantPast
    private var comboTimer: AnyCancellable?
    private var gameTimer: AnyCancellable?
    private var bonusMoveTimer: Timer?
    private var doubleDashShowTimer: Timer?
    private var doubleDashHideTimer: Timer?
    
    private let locationManager = LocationManager.shared
    
    private var roundTimeLeft: Double = 10.0
    private var currentRound: Int = 1
    private var isBonusActive: Bool = false
    private var doubleDashUsedThisRound = false
    
    init() {
        locationManager.requestPermissions()
    }
    
    func startGame() {
        score = 0
        level = 1
        currentRound = 1
        isGameOver = false
        startRound()
    }
    
    func processClick(isInsideBall: Bool) {
        if isInsideBall {
            if !isBonusActive {
                score = max(0, score - 50)
                comboMultiplier = 1
            } else {
                let now = Date()
                if now.timeIntervalSince(lastTapTime) < 0.5 {
                    comboMultiplier = min(comboMultiplier + 1, 10)
                } else {
                    comboMultiplier = 1
                }
                lastTapTime = now
                score += (200 * comboMultiplier)
                SoundManager.shared.playGreenTap()
            }
            moveBall()
        } else {
            // Tapped outside
            comboMultiplier = 1
            score = max(0, score - 50)
        }
    }
    func processDoubleDashClick() {
        guard showDoubleDash else { return }
        score *= 2
        doubleDashUsedThisRound = true
        hideDoubleDash()
    }
    
    private func moveBall() {
        let newX = CGFloat.random(in: 50...350)
        let newY = CGFloat.random(in: 100...700)
        withAnimation(.spring()) {
            ballPosition = CGPoint(x: newX, y: newY)
        }
    }
    
    private func randomDashPosition() -> CGPoint {
        CGPoint(
            x: CGFloat.random(in: 60...340),
            y: CGFloat.random(in: 120...650)
        )
    }
    
    private func hideDoubleDash() {
        showDoubleDash = false
        doubleDashHideTimer?.invalidate()
        doubleDashHideTimer = nil
    }
    
    private func scheduleDoubleDash() {
        doubleDashUsedThisRound = false
        doubleDashShowTimer?.invalidate()
        doubleDashHideTimer?.invalidate()
        
        let delay = Double.random(in: 1.0...6.0)
        doubleDashShowTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            guard let self = self, !self.isGameOver, !self.doubleDashUsedThisRound else { return }
            self.doubleDashPosition = self.randomDashPosition()
            withAnimation(.spring()) {
                self.showDoubleDash = true
            }
            self.doubleDashHideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                self?.hideDoubleDash()
            }
        }
    }
    
    private func startRound() {
        roundTimeLeft = 10.0
        scheduleDoubleDash()
        
        gameTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            self.roundTimeLeft -= 0.1
            self.ballScale = CGFloat(self.roundTimeLeft / 10.0)
            
            if self.roundTimeLeft <= 0 {
                self.endRound()
            }
        }
        
        bonusMoveTimer?.invalidate()
            bonusMoveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                
                // 1. Determine new state
                let isBonus = Bool.random()
                
                // 2. Apply penalty ONLY if it just turned grey
                if !isBonus && self.isBonusActive {
                    // Optional: Only penalize if it was previously NOT grey
                }
                
                // Update properties
                self.ballColor = isBonus ? .green : .gray
                self.isBonusActive = isBonus
                
                // If it turned gray, apply the penalty immediately
                if !isBonus {
                    self.score = max(0, self.score - 50)
                }
                
                self.moveBall()
            }
    }
    
    private func endRound() {
        gameTimer?.cancel()
        bonusMoveTimer?.invalidate()
        bonusMoveTimer = nil
        doubleDashShowTimer?.invalidate()
        doubleDashShowTimer = nil
        hideDoubleDash()
        
        if currentRound < 3 {
            currentRound += 1
            level = currentRound
            startRound()
        } else {
            isGameOver = true
            updateHighScore()
            saveSession()
        }
    }
    
    private func updateHighScore() {
        let current = UserDefaults.standard.integer(forKey: HighScoreKeys.tapFrenzy)
        if score > current {
            UserDefaults.standard.set(score, forKey: HighScoreKeys.tapFrenzy)
        }
    }
    
    private func saveSession() {
        let coord = locationManager.lastLocation?.coordinate ?? locationManager.lastKnownCoordinate
        let fallbackLat = 6.9271
        let fallbackLon = 79.8612
        let newSession = GameSession(
            mode: "Tap Frenzy",
            score: score,
            timestamp: Date(),
            latitude: coord?.latitude ?? fallbackLat,
            longitude: coord?.longitude ?? fallbackLon
        )
        SessionManager().save(newSession)
    }
    
    func resetGame() {
        gameTimer?.cancel()
        bonusMoveTimer?.invalidate()
        bonusMoveTimer = nil
        doubleDashShowTimer?.invalidate()
        doubleDashShowTimer = nil
        hideDoubleDash()
        startGame()
    }
}

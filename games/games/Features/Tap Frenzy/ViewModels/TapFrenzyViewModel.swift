import SwiftUI
import Combine
import CoreLocation

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
    
    // Added Location Support
    private let locationManager = LocationManager()
    
    private var roundTimeLeft: Double = 10.0
    private var currentRound: Int = 1
    private var isBonusActive: Bool = false
    
    init() {
        locationManager.requestPermissions() // Request on init
        startRound()
    }
    
    func processClick(isInsideBall: Bool) {
        if isInsideBall {
            let now = Date()
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
        
        gameTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            self.roundTimeLeft -= 0.1
            self.ballScale = CGFloat(self.roundTimeLeft / 10.0)
            
            if self.roundTimeLeft <= 0 {
                self.endRound()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
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
            saveSession() // Save when game over
        }
    }
    
    private func saveSession() {
        let coord = locationManager.lastLocation?.coordinate
        let newSession = GameSession(
            mode: "Tap Frenzy",
            score: score,
            timestamp: Date(),
            latitude: coord?.latitude ?? 0.0,
            longitude: coord?.longitude ?? 0.0
        )
        SessionManager().save(newSession)
    }
    
    func resetGame() {
        score = 0
        level = 1
        currentRound = 1
        isGameOver = false
        startRound()
    }
}

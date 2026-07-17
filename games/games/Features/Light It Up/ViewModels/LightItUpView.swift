import SwiftUI
import Combine
import CoreLocation

struct LightItUpView: View {
    @State private var score = 0
    @State private var lives = 3
    @State private var elapsedTime: TimeInterval = 0
    @State private var round = 1
    @State private var isGameOver = false
    @State private var currentLevel = GameLevel.config(elapsedTime: 0, round: 1)
    @State private var cards: [Card] = []
    @AppStorage(HighScoreKeys.lightItUp) private var highScore = 0

    @State private var showSettings = false
    @AppStorage("maxGameTime") private var maxGameTime: TimeInterval = 60
    @State private var showLevelFlash = false
    @State private var hasStarted = false

    @StateObject private var locationManager = LocationManager.shared

    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State private var gameTickTimer: AnyCancellable?

    var body: some View {
        ZStack {
            Image("grass").resizable().scaledToFill().ignoresSafeArea()

            if !hasStarted {
                LightItUpStartView { hasStarted = true; setupGame() }
            } else if !isGameOver {
                VStack(spacing: 20) {
                    LightItUpHeaderView(
                        levelNumber: currentLevel.levelNumber,
                        round: round,
                        elapsedTime: elapsedTime,
                        score: score,
                        lives: lives,
                        onSettingsTap: { showSettings = true }
                    )

                    LazyVGrid(columns: currentLevel.columns, spacing: 15) {
                        ForEach(cards) { card in
                            CardView(card: card) { handleTap(card) }
                        }
                    }
                    .padding(25)
                    Spacer()
                }
            } else {
                LightItUpGameOverView(score: score, onPlayAgain: setupGame)
            }

            if showLevelFlash { Color.white.opacity(0.7).ignoresSafeArea().allowsHitTesting(false) }
        }
        .onAppear { locationManager.requestPermissions() }
        .onReceive(timer) { _ in
            guard hasStarted, !isGameOver else { return }
            elapsedTime += 1
            if elapsedTime >= maxGameTime { endGame() }
            let oldLevel = currentLevel.levelNumber
            let newLevel = min(4, Int(elapsedTime / 15) + 1)
            if newLevel != oldLevel { round = 1; triggerFlash() }
            else if Int(elapsedTime) % 5 == 0 && round < 3 { round += 1 }
            updateState()
        }
        .sheet(isPresented: $showSettings) { LevelSettingsView(maxTime: $maxGameTime) }
    }

    private func setupGame() {
        score = 0; lives = 3; elapsedTime = 0; round = 1; isGameOver = false
        currentLevel = GameLevel.config(elapsedTime: 0, round: 1)
        cards = (0..<currentLevel.cardCount).map { Card(id: $0) }
        updateState()
    }

    private func updateState() {
        let newConfig = GameLevel.config(elapsedTime: elapsedTime, round: round)
        if newConfig.levelNumber != currentLevel.levelNumber || newConfig.roundNumber != currentLevel.roundNumber || newConfig.cardCount != currentLevel.cardCount {
            currentLevel = newConfig
            cards = (0..<currentLevel.cardCount).map { Card(id: $0) }
            startLightingLoop()
        }
    }

    private func startLightingLoop() {
        gameTickTimer?.cancel()
        gameTickTimer = Timer.publish(every: currentLevel.litDuration, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                cards.indices.forEach { cards[$0].isLit = false; cards[$0].litColor = nil }
                cards.shuffled().prefix(currentLevel.countToLight).forEach { card in
                    cards[card.id].isLit = true
                    // Logic for two colors on level 4
                    cards[card.id].litColor = (currentLevel.levelNumber == 4) ? (Bool.random() ? .yellow : .blue) : .yellow
                }
            }
    }

    private func handleTap(_ card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        if cards[index].isLit {
            score += (10 * currentLevel.levelNumber * round)
            cards[index].isLit = false
            cards[index].litColor = nil
            SoundManager.shared.playCorrect()
        } else {
            lives -= 1
            if lives <= 0 { endGame() }
            SoundManager.shared.playIncorrect()
        }
    }

    private func triggerFlash() {
        withAnimation(.easeOut(duration: 0.5)) { showLevelFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation(.easeIn(duration: 0.5)) { showLevelFlash = false } }
    }

    private func endGame() {
        isGameOver = true
        gameTickTimer?.cancel()
        let coord = locationManager.lastLocation?.coordinate ?? locationManager.lastKnownCoordinate
        let newSession = GameSession(mode: "Light It Up", score: score, timestamp: Date(),
                                     latitude: coord?.latitude ?? 6.9271, longitude: coord?.longitude ?? 79.8612)
        SessionManager().save(newSession)
        if score > highScore { highScore = score }
    }
}

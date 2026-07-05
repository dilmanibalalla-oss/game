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
    
    @StateObject private var locationManager = LocationManager.shared
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State private var gameTickTimer: AnyCancellable?
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.1).ignoresSafeArea()
            
            if !isGameOver {
                VStack(spacing: 20) {
                    headerView
                    LazyVGrid(columns: currentLevel.columns, spacing: 15) {
                        ForEach(cards) { card in
                            CardView(card: card, level: currentLevel.levelNumber, round: round)
                                .aspectRatio(1.0, contentMode: .fit)
                                .onTapGesture { handleTap(card) }
                        }
                    }
                    .padding(25)
                    Spacer()
                }
            } else {
                gameOverView
            }
            
            if showLevelFlash {
                Color.white.opacity(0.7).ignoresSafeArea().allowsHitTesting(false)
            }
        }
        .onAppear {
            locationManager.requestPermissions()
            setupGame()
        }
        .onReceive(timer) { _ in
            if !isGameOver {
                elapsedTime += 1
                if elapsedTime >= maxGameTime { endGame() }
                
                let oldLevel = currentLevel.levelNumber
                let newLevel = min(4, Int(elapsedTime / 15) + 1)
                
                if newLevel != oldLevel {
                    round = 1
                    triggerFlash()
                } else if Int(elapsedTime) % 5 == 0 && round < 3 {
                    round += 1
                }
                updateState()
            }
        }
        .sheet(isPresented: $showSettings) { LevelSettingsView(maxTime: $maxGameTime) }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("L: \(currentLevel.levelNumber) | R: \(round) | T: \(Int(elapsedTime))s")
                Text("Score: \(score)").font(.title2).bold()
            }
            Spacer()
            Button("Settings") { showSettings = true }
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart").foregroundColor(.red)
                }
            }
        }.padding()
    }

    private func triggerFlash() {
        withAnimation(.easeOut(duration: 0.5)) { showLevelFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.5)) { showLevelFlash = false }
        }
    }
    
    private func updateState() {
        let newConfig = GameLevel.config(elapsedTime: elapsedTime, round: round)
        if newConfig.levelNumber != currentLevel.levelNumber ||
           newConfig.roundNumber != currentLevel.roundNumber ||
           newConfig.cardCount != currentLevel.cardCount {
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
                cards.indices.forEach { cards[$0].isLit = false }
                cards.shuffled().prefix(currentLevel.countToLight).forEach { cards[$0.id].isLit = true }
            }
    }
    
    private func handleTap(_ card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        if cards[index].isLit {
            withAnimation(.spring()) {
                score += (10 * currentLevel.levelNumber * round)
                cards[index].isLit = false
            }
        } else {
            lives -= 1
            if lives <= 0 { endGame() }
        }
    }
    
    private func endGame() {
        isGameOver = true
        gameTickTimer?.cancel()
        let coord = locationManager.lastLocation?.coordinate ?? locationManager.lastKnownCoordinate
        let fallbackLat = 6.9271
        let fallbackLon = 79.8612
        let newSession = GameSession(mode: "Light It Up", score: score, timestamp: Date(),
                                     latitude: coord?.latitude ?? fallbackLat, longitude: coord?.longitude ?? fallbackLon)
        SessionManager().save(newSession) // Assumes SessionManager exists
        if score > highScore { highScore = score }
    }
    
    private func setupGame() {
        score = 0; lives = 3; elapsedTime = 0; round = 1; isGameOver = false
        updateState()
    }
    
    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.largeTitle).bold()
            Text("Final Score: \(score)").font(.title)
            Text("High Score: \(highScore)").font(.subheadline)
            ShareLink(item: "I just scored \(score) on Light It Up, beat that!")
            Button("Play Again") { setupGame() }.buttonStyle(.borderedProminent)
        }
    }
}

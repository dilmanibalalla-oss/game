import SwiftUI
import Combine

struct LightItUpView: View {
    @State private var score = 0
    @State private var lives = 3
    @State private var level = 1
    @State private var round = 1
    @State private var isGameOver = false
    @State private var currentLevel = GameLevel.config(level: 1, round: 1)
    @State private var cards: [Card] = []
    @AppStorage("lightItUpHighScore") private var highScore = 0
    
    @State private var roundTimer = Timer.publish(every: 20.0, on: .main, in: .common).autoconnect()
    @State private var gameTickTimer: AnyCancellable?
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.1).ignoresSafeArea()
            
            if !isGameOver {
                VStack(spacing: 20) {
                    headerView
                    
                    LazyVGrid(columns: currentLevel.columns, spacing: 15) {
                        ForEach(cards) { card in
                            CardView(card: card, level: level, round: round)
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
        }
        .onAppear(perform: setupGame)
        .onReceive(roundTimer) { _ in
            if !isGameOver { advanceRound() }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Level \(level) | Round \(round)").font(.headline)
                Text("Score: \(score)").font(.title2).bold()
            }
            Spacer()
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart").foregroundColor(.red)
                }
            }
        }.padding()
    }
    
    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.largeTitle).bold()
            Text("Final Score: \(score)").font(.title)
            Text("High Score: \(highScore)").font(.subheadline)
            Button("Play Again") { setupGame() }.buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - Game Logic
    private func handleTap(_ card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        
        if cards[index].isLit {
            withAnimation(.spring()) {
                score += (10 * level * round)
                cards[index].isLit = false
            }
        } else {
            lives -= 1
            if lives <= 0 { endGame() }
        }
    }
    
    private func advanceRound() {
        if round < 3 {
            round += 1
        } else if level < 3 {
            level += 1
            round = 1
        } else {
            endGame()
            return
        }
        updateLevelConfig()
    }
    
    private func updateLevelConfig() {
        currentLevel = GameLevel.config(level: level, round: round)
        cards = (0..<currentLevel.cardCount).map { Card(id: $0) }
        startLightingLoop()
    }
    
    private func startLightingLoop() {
        gameTickTimer?.cancel()
        gameTickTimer = Timer.publish(every: currentLevel.litDuration, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                // Reset and light new random cards
                cards.indices.forEach { cards[$0].isLit = false }
                let shuffledIndices = cards.indices.shuffled()
                let toLight = shuffledIndices.prefix(currentLevel.countToLight)
                for i in toLight { cards[i].isLit = true }
            }
    }
    
    private func endGame() {
        isGameOver = true
        gameTickTimer?.cancel()
        if score > highScore { highScore = score }
    }
    
    private func setupGame() {
        score = 0
        lives = 3
        level = 1
        round = 1
        isGameOver = false
        updateLevelConfig()
    }
}

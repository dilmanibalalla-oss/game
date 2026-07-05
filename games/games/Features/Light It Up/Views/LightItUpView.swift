import SwiftUI
import Combine

struct LightItUpView: View {
    @State private var score = 0
    @State private var roundTime: TimeInterval = 60.0
    @State private var isGameOver = false
    @State private var currentLevel: GameLevel = GameLevel.config(forScore: 0)
    @State private var cards: [Card] = []
    @State private var scoreScale: CGFloat = 1.0
    @State private var showingHighScores = false
    @AppStorage("lightItUpHighScore") private var highScore = 0
    
    private let sessionManager = SessionManager()
    
    let roundTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State private var gameTickTimer: AnyCancellable?
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.2).ignoresSafeArea()
            
            if !isGameOver {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Score: \(score)")
                                .font(.title2)
                                .bold()
                                .scaleEffect(scoreScale)
                            Text("Level: \(currentLevel.levelNumber)").font(.subheadline)
                            Text("Best: \(highScore)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(String(format: "Time: %.0fs", roundTime)).font(.title2).bold()
                        
                        Button {
                            showingHighScores = true
                        } label: {
                            Label("High Scores", systemImage: "trophy.fill")
                                .font(.subheadline)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.yellow.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }.padding(.horizontal)
                    
                    LazyVGrid(columns: currentLevel.columns, spacing: 15) {
                        ForEach(cards) { card in
                            CardView(card: card)
                                .aspectRatio(1.0, contentMode: .fit)
                                .onTapGesture { handleCardTap(card) }
                        }
                    }
                    .padding(25)
                }
            } else {
                VStack {
                    Text("Final Score: \(score)").font(.largeTitle)
                    Button("Play Again") { resetGame() }
                        .padding()
                }
            }
        }
        .onAppear { setupGame() }
        .onReceive(roundTimer) { _ in
            if !isGameOver && roundTime > 0 { roundTime -= 1 }
            else if roundTime == 0 { endGame() }
        }
        .sheet(isPresented: $showingHighScores) {
            VStack(spacing: 16) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.yellow)
                Text("High Scores")
                    .font(.title)
                    .bold()
                Text("Best Score: \(highScore)")
                    .font(.title2)
                Button("Close") {
                    showingHighScores = false
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
    
    private func handleCardTap(_ tappedCard: Card) {
        guard let index = cards.firstIndex(where: { $0.id == tappedCard.id }) else { return }
        
        if cards[index].isLit {
            let bonus = currentLevel.levelNumber * 2
            
            withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                score += (10 + bonus)
                scoreScale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation { scoreScale = 1.0 }
            }
            
            cards[index].isLit = false
            refreshLevel()
        } else {
            score = max(0, score - 5)
        }
    }
    
    private func refreshLevel() {
        let newLevel = GameLevel.config(forScore: score)
        if newLevel.levelNumber != currentLevel.levelNumber || cards.isEmpty {
            currentLevel = newLevel
            cards = (0..<currentLevel.cardCount).map { Card(id: $0) }
            startLightingLoop()
        }
    }
    
    private func startLightingLoop() {
        gameTickTimer?.cancel()
        gameTickTimer = Timer.publish(every: currentLevel.litDuration, on: .main, in: .common)
            .autoconnect()
            .sink { _ in self.lightUpRandomCards() }
    }
    
    private func lightUpRandomCards() {
        cards.indices.forEach { cards[$0].isLit = false }
        let indicesToLight = Array(0..<cards.count).shuffled().prefix(currentLevel.countToLight)
        for index in indicesToLight { cards[index].isLit = true }
    }
    
    private func endGame() {
        isGameOver = true
        gameTickTimer?.cancel()
        if score > highScore { highScore = score }
        
        // Integration: Save session data
        let newSession = GameSession(
            mode: "Light It Up",
            score: score,
            timestamp: Date(),
            latitude: 6.9271,
            longitude: 79.8612
        )
        sessionManager.save(newSession)
    }
    
    private func resetGame() {
        setupGame()
    }

    private func setupGame() {
        score = 0
        roundTime = 60.0
        isGameOver = false
        currentLevel = GameLevel.config(forScore: 0)
        cards = (0..<currentLevel.cardCount).map { Card(id: $0) }
        gameTickTimer?.cancel()
        startLightingLoop()
    }
}

import SwiftUI
import Combine

struct LightItUpView: View {
    @State private var score = 0
    @State private var roundTime: TimeInterval = 60.0
    @State private var isGameOver = false
    @State private var currentLevel: GameLevel = GameLevel.config(forTimeElapsed: 0)
    @State private var cards: [LightItUpCard] = []
    @AppStorage("lightItUpHighScore") private var highScore = 0
    
    let roundTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State private var gameTickTimer: AnyCancellable?
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.2)
                .ignoresSafeArea()
            
            if !isGameOver {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Score: \(score)").font(.title2).bold()
                            Text("High Score: \(highScore)").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(String(format: "Time: %.0fs", roundTime))
                                .font(.title2).bold()
                                .foregroundColor(roundTime <= 10 ? .red : .primary)
                            Text("Level: \(currentLevel.levelNumber)")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Dynamic Whack-a-Mole Grid Engine powered by currentLevel structural bounds
                    LazyVGrid(columns: currentLevel.columns, spacing: 15) {
                        ForEach(cards) { card in
                            LightItUpCardView(card: card)
                                .aspectRatio(1.0, contentMode: .fit)
                                .onTapGesture {
                                    handleCardTap(card)
                                }
                        }
                    }
                    .padding(25)
                    .animation(.easeInOut(duration: 0.2), value: cards)
                    
                    Spacer()
                }
            } else {
                // MARK: Game Over Terminal View
                VStack(spacing: 20) {
                    Text("Game Over")
                        .font(.largeTitle).bold()
                        .foregroundColor(.red)
                    
                    Text("Final Score: \(score)")
                        .font(.title)
                    
                    if score >= highScore && score > 0 {
                        Text(" New High Score! ")
                            .font(.title3).bold()
                            .foregroundColor(.green)
                    }
                    
                    Button(action: resetGame) {
                        Text("Play Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupGame()
        }
        .onDisappear {
            stopTimers()
        }
        // Round controller system
        .onReceive(roundTimer) { _ in
            guard !isGameOver else { return }
            if roundTime > 1 {
                roundTime -= 1
                updateLevelProgression()
            } else {
                roundTime = 0
                endGame()
            }
        }
    }
    
    // MARK: Game Engine Subsystems
    private func setupGame() {
        updateLevelProgression()
    }
    
    private func updateLevelProgression() {
        let timeElapsed = 60.0 - roundTime
        let targetLevel = GameLevel.config(forTimeElapsed: timeElapsed)
        
        // Layout structure shifts dynamically only when the calculated step increases
        if targetLevel.levelNumber != currentLevel.levelNumber || cards.isEmpty {
            currentLevel = targetLevel
            cards = (0..<currentLevel.cardCount).map { LightItUpCard(id: $0) }
            startLightingLoop()
        }
    }
    
    private func startLightingLoop() {
        gameTickTimer?.cancel()
        
        // Pacing matches your structural calculation step parameters automatically
        gameTickTimer = Timer.publish(every: currentLevel.litDuration, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.lightUpRandomCards()
            }
    }
    
    private func lightUpRandomCards() {
        for i in 0..<cards.count {
            cards[i].isLit = false
        }
        
        let shuffledIndices = Array(0..<cards.count).shuffled()
        let indicesToLight = shuffledIndices.prefix(min(currentLevel.countToLight, cards.count))
        
        for index in indicesToLight {
            cards[index].isLit = true
        }
    }
    
    private func handleCardTap(_ tappedCard: LightItUpCard) {
        guard let index = cards.firstIndex(where: { $0.id == tappedCard.id }) else { return }
        
        if cards[index].isLit {
            score += 10
            cards[index].isLit = false
        } else {
            score = max(0, score - 5)
        }
    }
    
    private func endGame() {
        isGameOver = true
        stopTimers()
        if score > highScore {
            highScore = score
        }
    }
    
    private func stopTimers() {
        gameTickTimer?.cancel()
    }
    
    private func resetGame() {
        score = 0
        roundTime = 60.0
        isGameOver = false
        setupGame()
    }
}

// MARK: - Game Data Components
struct LightItUpCard: Identifiable, Equatable {
    let id: Int
    var isLit: Bool = false
}

// MARK: - Support Subviews
struct LightItUpCardView: View {
    let card: LightItUpCard
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(card.isLit ? Color.yellow : Color.gray.opacity(0.5))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(card.isLit ? Color.orange : Color.clear, lineWidth: 3)
            )
            .shadow(color: card.isLit ? .yellow.opacity(0.6) : .clear, radius: 8)
    }
}

// MARK: - Preview Setup
#Preview {
    NavigationView {
        LightItUpView()
    }
}

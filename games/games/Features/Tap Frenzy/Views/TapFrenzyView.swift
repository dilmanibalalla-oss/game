import SwiftUI

struct TapFrenzyView: View {
    @StateObject private var viewModel = TapFrenzyViewModel()
    
    var body: some View {
        ZStack {
            // Main Game Layer
            if !viewModel.isGameOver {
                ZStack {
                    // 1. Background layer handles "Miss" clicks
                    Color.black.opacity(0.05)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.processClick(isInsideBall: false)
                        }
                    
                    VStack {
                        HStack {
                            Text("Score: \(viewModel.score)")
                            Spacer()
                            Text("Level: \(viewModel.level)")
                        }
                        .font(.headline)
                        .padding()
                        
                        Text("Combo: \(viewModel.comboMultiplier)x")
                            .font(.title2.bold())
                            .foregroundColor(viewModel.comboMultiplier > 1 ? .red : .primary)
                        
                        Spacer()
                    }
                    
                    Circle()
                        .fill(viewModel.ballColor)
                        .frame(width: 100, height: 100)
                        .scaleEffect(viewModel.ballScale)
                        .position(viewModel.ballPosition)
                        .onTapGesture {
                            viewModel.processClick(isInsideBall: true)
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: viewModel.ballPosition)
                        .animation(.linear(duration: 0.1), value: viewModel.ballScale)
                }
            } else {
                // Game Over Overlay
                VStack(spacing: 20) {
                    Text("Game Over!")
                        .font(.largeTitle.bold())
                    Text("Final Score: \(viewModel.score)")
                        .font(.title)
                    Button(action: {
                        viewModel.resetGame()
                    }) {
                        Text("Play Again")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .navigationTitle("Tap Frenzy")
    }
}



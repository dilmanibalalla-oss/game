import SwiftUI

struct TapFrenzyView: View {
    @StateObject private var viewModel = TapFrenzyViewModel()
    
    private var buttonScale: CGFloat {
        let levelGrowth = 1.0 + (0.10 * Double(viewModel.level - 1))
        return min(2.0, viewModel.ballScale * levelGrowth)
    }
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.2).ignoresSafeArea()
            
            if !viewModel.isGameOver {
                VStack(spacing: 20) {
                    Text("Level: \(viewModel.level) | Score: \(viewModel.score)")
                        .font(.headline)
                    
                    Text(String(format: "Time: %.1fs", viewModel.timeRemaining))
                        .font(.largeTitle)
                        .bold()
                    
                    GeometryReader { _ in
                        ZStack {
                            Circle()
                                .fill(Color.blue.gradient)
                                .frame(width: 150 * buttonScale)
                                .onTapGesture { viewModel.processClick(isInsideBall: true) }
                                .overlay(Text("TAP!").bold().foregroundColor(.white))
                            
                            // Safely unwrap optionals to avoid binding errors
                            if let bonus = viewModel.bonusPosition {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 40))
                                    .position(bonus)
                                    .onTapGesture { viewModel.processClick(isInsideBall: true, isBonus: true) }
                            }
                            
                            if let trap = viewModel.trapPosition {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 40))
                                    .position(trap)
                                    .onTapGesture { viewModel.processClick(isInsideBall: false) }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture { viewModel.processClick(isInsideBall: false) }
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Final Score: \(viewModel.score)")
                        .font(.title)
                    
                    Text("High Score: \(viewModel.highScore)")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Button("Play Again") {
                        viewModel.resetGame()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
        .navigationTitle("Tap Frenzy")
    }
}

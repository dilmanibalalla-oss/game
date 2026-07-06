import SwiftUI

struct TapFrenzyView: View {
    @StateObject private var viewModel = TapFrenzyViewModel()
    @State private var hasStarted = false
    
    var body: some View {
        ZStack {
            Image("image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Adding a dark overlay for better text contrast against the image
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            if !hasStarted {
                VStack(spacing: 25) {
                    Text("Tap Frenzy")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Tap the ball, build combos, and catch the 2x dash once per round!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        hasStarted = true
                        viewModel.startGame()
                    } label: {
                        Text("Start Game")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                }
                .padding()
            } else if !viewModel.isGameOver {
                ZStack {
                    
                    VStack {
                        HStack {
                            Text("Score: \(viewModel.score)")
                            Spacer()
                            Text("Level: \(viewModel.level)")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        
                        Text("Combo: \(viewModel.comboMultiplier)x")
                            .font(.title2.bold())
                            .foregroundColor(viewModel.comboMultiplier > 1 ? .yellow : .white)
                        
                        if viewModel.showDoubleDash {
                            Text("2x DASH!")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange)
                                .cornerRadius(8)
                        }
                        
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
                    
                    if viewModel.showDoubleDash {
                        ZStack {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 70, height: 70)
                                .shadow(color: .orange, radius: 8)
                            Text("2x")
                                .font(.title2.bold())
                                .foregroundColor(.black)
                        }
                        .position(viewModel.doubleDashPosition)
                        .onTapGesture {
                            viewModel.processDoubleDashClick()
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .onTapGesture {
                    viewModel.processClick(isInsideBall: false)
                }
            } else {
                VStack(spacing: 20) {
                    Text("Game Over!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Text("Final Score: \(viewModel.score)")
                        .font(.title)
                        .foregroundColor(.white)
                    ShareLink(item: "I just scored \(viewModel.score) on Tap Frenzy, beat that!")
                        .foregroundColor(.white)
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

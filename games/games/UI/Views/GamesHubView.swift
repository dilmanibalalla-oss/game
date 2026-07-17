import SwiftUI

struct GamesHubView: View {
    @State private var showHighScores = false
    @State private var shimmer = false

    var body: some View {
        ZStack {
           
            Image("sky")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("Games Hub")
                    .font(AppFonts.pageTitle)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                Text("Tap the games to play")
                    .font(AppFonts.sectionTitle)
                    .foregroundColor(.white)
                   
                
                VStack(spacing: 20) {
                    gameNavLink(destination: TapFrenzyView(), title: "Tap Frenzy", icon: "hand.tap.fill")
                    gameNavLink(destination: LightItUpView(), title: "Light It Up", icon: "lightbulb.fill")
                    gameNavLink(destination: QuizView(), title: "Quiz Rush", icon: "questionmark.circle.fill")
                    
                    Button { showHighScores = true } label: {
                        gameButtonContent(title: "High Scores", icon: "trophy.fill")
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
        }
        .onAppear {
            shimmer = true
            HighScoreKeys.migrateIfNeeded()
        }
        .fullScreenCover(isPresented: $showHighScores) { HighScoresView() }
    }

    @ViewBuilder
    func gameNavLink<V: View>(destination: V, title: String, icon: String) -> some View {
        NavigationLink(destination: destination) {
            gameButtonContent(title: title, icon: icon)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    func gameButtonContent(title: String, icon: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon).font(.title).foregroundStyle(AppColors.skyMid)
            VStack(alignment: .leading) {
                Text(title).font(.title2).bold().foregroundStyle(AppColors.textPrimary)
                Text("Tap the games to play")
                    .font(.caption).bold().foregroundStyle(AppColors.skyMid)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(AppColors.textPrimary.opacity(0.5))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(AppColors.cardBg))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [.clear, .white.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing))
                .offset(x: shimmer ? 300 : -300)
                .rotationEffect(.degrees(20))
                .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: shimmer)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

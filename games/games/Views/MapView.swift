import SwiftUI

struct MapView: View {
    @State private var sessions: [GameSession] = []
    @State private var selectedSession: GameSession?
    @State private var showingScore = false
    private let sessionManager = SessionManager()
    
    private func pinColor(for mode: String) -> Color {
        switch mode {
        case "Light It Up":
            return .pink
        case "Tap Frenzy":
            return .green
        case "Quiz":
            return .orange
        default:
            return .blue
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.blue.opacity(0.1).ignoresSafeArea()
                
                ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                    let offset = CGFloat(index % 5) * 5
                    let x = (CGFloat(session.longitude) / 100 * geometry.size.width) + offset
                    let y = (CGFloat(session.latitude) / 100 * geometry.size.height) + offset
                    
                    Button {
                        selectedSession = session
                        showingScore = true
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 30))
                                // Explicitly casting the result to ensure SwiftUI renders it
                                .foregroundStyle(self.pinColor(for: session.mode))
                                .shadow(radius: 2)
                            
                            Text(session.mode)
                                .font(.caption2)
                                .bold()
                                .padding(4)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    .position(x: x, y: y)
                }
            }
        }
        .navigationTitle("Map of Games")
        .onAppear { self.sessions = sessionManager.fetchAll() }
        .alert(selectedSession?.mode ?? "Game", isPresented: $showingScore, presenting: selectedSession) { _ in
            Button("OK", role: .cancel) { }
        } message: { session in
            Text("Final Score: \(session.score)")
        }
    }
}

import SwiftUI

struct MapView: View {
    @State private var sessions: [GameSession] = []
    @State private var selectedSession: GameSession?
    @State private var showingScore = false
    private let sessionManager = SessionManager()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.blue.opacity(0.1).ignoresSafeArea()
                
                // Using enumerated() to offset overlapping pins
                ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                    let offset = CGFloat(index % 5) * 5 // Slight shift for collisions
                    let x = (CGFloat(session.longitude) / 100 * geometry.size.width) + offset
                    let y = (CGFloat(session.latitude) / 100 * geometry.size.height) + offset
                    
                    Button {
                        selectedSession = session
                        showingScore = true
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(.red)
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

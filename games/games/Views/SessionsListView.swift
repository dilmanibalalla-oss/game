import SwiftUI

struct SessionListView: View {
    let cluster: SessionCluster
    @Environment(\.dismiss) var dismiss
    
    // Group sessions by mode/game name
    private var groupedSessions: [String: [GameSession]] {
        Dictionary(grouping: cluster.sessions) { $0.mode }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if cluster.sessions.isEmpty {
                    Text("No sessions played at this location yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(groupedSessions.keys.sorted(), id: \.self) { gameMode in
                        Section(header: Text(gameMode).font(.headline)) {
                            ForEach(groupedSessions[gameMode] ?? []) { session in
                                HStack {
                                    Text(session.timestamp.formatted())
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(session.score) pts")
                                        .bold()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Sessions at Location")
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}

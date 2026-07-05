//
//  StatsView.swift
//  games
//
//  Created by student5 on 2026-07-05.
//

import SwiftUI
import Charts

struct StatsView: View {
    @State private var sessions: [GameSession] = []
    private let sessionManager = SessionManager()
    
    var body: some View {
        List {
            // 1. Overview Section
            Section("Overview") {
                HStack {
                    StatBox(title: "Total Games", value: "\(sessions.count)")
                    StatBox(title: "High Score", value: "\(sessions.map { $0.score }.max() ?? 0)")
                }
            }
            
            // 2. Chart Section
            Section("Performance by Mode") {
                if sessions.isEmpty {
                    Text("No games played yet.")
                        .foregroundStyle(.secondary)
                } else {
                    Chart(sessions) { session in
                        BarMark(
                            x: .value("Mode", session.mode),
                            y: .value("Score", session.score)
                        )
                        .foregroundStyle(by: .value("Mode", session.mode))
                    }
                    .frame(height: 200)
                }
            }
            
            // 3. Recent Games Section
            Section("Recent Games") {
                if sessions.isEmpty {
                    Text("No recent games.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sessions.suffix(5).reversed()) { session in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(session.mode).font(.headline)
                                Text(session.timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(session.score)").bold()
                        }
                    }
                }
            }
        }
        .navigationTitle("Statistics")
        .onAppear {
            // Correctly calling fetchAll() as defined in your SessionManager
            self.sessions = sessionManager.fetchAll()
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

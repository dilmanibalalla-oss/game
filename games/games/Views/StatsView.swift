import SwiftUI
import Charts

struct StatsView: View {
    @State private var sessions: [GameSession] = []
    private let sessionManager = SessionManager()

    var body: some View {
        ZStack {
            // Background Image
            Image("sky")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Centered Title
                Text("Statistics")
                    .font(AppFonts.pageTitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)

                List {
                    Section {
                        HStack(spacing: 16) {
                            StatBox(title: "Total Games", value: "\(sessions.count)", cardColor: AppColors.cardBg, textColor: AppColors.textPrimary, accentColor: AppColors.warmAccent)
                            StatBox(title: "High Score", value: "\(sessions.map { $0.score }.max() ?? 0)", cardColor: AppColors.cardBg, textColor: AppColors.textPrimary, accentColor: AppColors.skyMid)
                        }
                    } header: {
                        Text("Overview").font(AppFonts.sectionTitle).foregroundColor(.white)
                    }
                    .listRowBackground(Color.clear)

                    Section {
                        if sessions.isEmpty {
                            Text("No games played yet.").foregroundStyle(AppColors.textSecondary).padding()
                        } else {
                            Chart(sessions) { session in
                                BarMark(x: .value("Mode", session.mode), y: .value("Score", session.score))
                                    .foregroundStyle(by: .value("Mode", session.mode))
                                    .cornerRadius(6)
                            }
                            .chartForegroundStyleScale(domain: Array(Set(sessions.map { $0.mode })).sorted(), range: AppColors.chartColors)
                            .frame(height: 200)
                            .padding(.vertical, 8)
                        }
                    } header: {
                        Text("Performance by Mode").font(AppFonts.sectionTitle).foregroundColor(.white)
                    }
                    .listRowBackground(RoundedRectangle(cornerRadius: 16).fill(AppColors.cardBg.opacity(0.85)))

                    Section {
                        ForEach(sessions.suffix(5).reversed()) { session in
                            RecentGameRow(session: session, cardColor: AppColors.cardBg, textColor: AppColors.textPrimary, secondaryColor: AppColors.textSecondary, accentColor: AppColors.warmAccent)
                        }
                    } header: {
                        Text("Recent Games").font(AppFonts.sectionTitle).foregroundColor(.white)
                    }
                    .listRowBackground(RoundedRectangle(cornerRadius: 16).fill(AppColors.cardBg.opacity(0.85)))
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
        }
        .navigationBarHidden(true)
        .onAppear { self.sessions = sessionManager.fetchAll() }
    }
}

struct StatBox: View {
    let title: String, value: String, cardColor: Color, textColor: Color, accentColor: Color
    var body: some View {
        VStack(spacing: 6) {
            Text(value).font(AppFonts.statValue).foregroundStyle(textColor)
            Text(title).font(.caption).fontWeight(.medium).foregroundStyle(textColor.opacity(0.6))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 20)
        .background(RoundedRectangle(cornerRadius: 20).fill(cardColor))
    }
}

struct RecentGameRow: View {
    let session: GameSession, cardColor: Color, textColor: Color, secondaryColor: Color, accentColor: Color
    var body: some View {
        HStack {
            Image(systemName: modeIcon).foregroundStyle(accentColor)
            VStack(alignment: .leading) {
                Text(session.mode).font(.headline).foregroundStyle(textColor)
                Text(session.timestamp, style: .date).font(.caption).foregroundStyle(secondaryColor)
            }
            Spacer()
            Text("\(session.score)").bold().foregroundStyle(textColor)
        }
        .padding(.vertical, 4)
    }
    private var modeIcon: String {
        switch session.mode.lowercased() {
        case "easy": return "leaf.fill"; case "medium": return "bolt.fill"; case "hard": return "flame.fill"; default: return "star.fill"
        }
    }
}

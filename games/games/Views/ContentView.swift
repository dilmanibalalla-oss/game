import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                GamesHubView()
            }
            .tabItem {
                Label("Games", systemImage: "gamecontroller.fill")
            }
            
            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            
            NavigationStack {
                MapView()
                    .navigationTitle("Map of Games")
            }
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }
            
            NavigationStack {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
}

#Preview {
    ContentView()
}

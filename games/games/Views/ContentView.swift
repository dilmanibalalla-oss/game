import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Tab 1: Games
            NavigationStack {
                GamesHubView()
            }
            .tabItem {
                Label("Games", systemImage: "gamecontroller.fill")
            }
            
            // Tab 2: Stats
            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            
            // Tab 3: Locations
            NavigationStack {
                Text("Map View")
                    .navigationTitle("Locations")
            }
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }
            
            // Tab 4: Settings
            NavigationStack {
                Text("App Settings")
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
}

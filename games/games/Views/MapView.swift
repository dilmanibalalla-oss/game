import SwiftUI
import MapKit

struct MapView: View {
    @State private var clusters: [SessionCluster] = []
    @State private var selectedCluster: SessionCluster?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    private let sessionManager = SessionManager()

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: clusters) { cluster in
            MapAnnotation(coordinate: cluster.coordinate) {
                Button { selectedCluster = cluster } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.red)
                        // Shows count of sessions at this location
                        Text("\(cluster.sessions.count)")
                            .font(.caption2).bold()
                            .padding(4).background(.ultraThinMaterial).clipShape(Circle())
                    }
                }
            }
        }
        .navigationTitle("Game Map")
        .onAppear(perform: loadAndCluster)
        .sheet(item: $selectedCluster) { cluster in
            SessionListView(cluster: cluster)
        }
    }

    private func loadAndCluster() {
        let allSessions = sessionManager.fetchAll()
        

        let grouped = Dictionary(grouping: allSessions) { session in
            "\(round(session.latitude * 1000)/1000),\(round(session.longitude * 1000)/1000)"
        }
        
        clusters = grouped.map { _, sessions in
            SessionCluster(coordinate: sessions[0].coordinate, sessions: sessions)
        }
    }
}

import SwiftUI
import MapKit

struct MapAnnotationItem: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let isUser: Bool
    let cluster: SessionCluster?
}

struct MapView: View {
    @State private var clusters: [SessionCluster] = []
    @State private var selectedCluster: SessionCluster?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    private let sessionManager = SessionManager()
    @StateObject private var locationManager = LocationManager.shared
    @State private var didCenterOnUser = false

    // Color Palette
    private let userPinColor = Color(red: 0.45, green: 0.36, blue: 0.68)
    private let clusterPinColor = Color(red: 0.62, green: 0.47, blue: 0.82)
    private let accentPinColor = Color(red: 0.36, green: 0.27, blue: 0.55)
    private let mapTint = Color(red: 0.90, green: 0.86, blue: 0.96)

    private var annotations: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []
        if let userLocation = locationManager.effectiveCoordinate {
            items.append(MapAnnotationItem(id: "user_location", coordinate: userLocation, isUser: true, cluster: nil))
        }
        for cluster in clusters {
            items.append(MapAnnotationItem(id: cluster.id.uuidString, coordinate: cluster.coordinate, isUser: false, cluster: cluster))
        }
        return items
    }

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient.skyBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Title Style
                Text("Game Map")
                    .font(AppFonts.pageTitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    .padding(.top, 20)

                ZStack(alignment: .bottomTrailing) {
                    Map(coordinateRegion: $region, showsUserLocation: false, annotationItems: annotations) { item in
                        MapAnnotation(coordinate: item.coordinate) {
                            if item.isUser {
                                Button {
                                    let userSessions = sessionsForUserLocation()
                                    selectedCluster = SessionCluster(coordinate: item.coordinate, sessions: userSessions)
                                } label: {
                                    VStack(spacing: 2) {
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 35))
                                            .foregroundColor(userPinColor)
                                            .background(AppColors.panelTint.clipShape(Circle()))
                                            .shadow(radius: 3)
                                        Text("You").font(.caption2).bold().foregroundColor(userPinColor)
                                            .padding(4).background(.ultraThinMaterial).clipShape(Capsule())
                                    }
                                }
                            } else if let cluster = item.cluster {
                                Button { selectedCluster = cluster } label: {
                                    VStack(spacing: 2) {
                                        Image(systemName: "mappin.circle.fill").font(.system(size: 30)).foregroundColor(clusterPinColor)
                                        Text("\(cluster.sessions.count)").font(.caption2).bold().foregroundColor(clusterPinColor)
                                            .padding(4).background(.ultraThinMaterial).clipShape(Circle())
                                    }
                                }
                            }
                        }
                    }
                    .colorMultiply(mapTint)
                    .cornerRadius(20)
                    .padding()

                    // Floating Controls
                    VStack(spacing: 12) {
                        if locationManager.effectiveCoordinate != nil {
                            Button(action: centerOnUser) {
                                Image(systemName: "location.fill").font(.title2).foregroundColor(userPinColor).padding(12)
                                    .background(AppColors.panelTint).clipShape(Circle()).shadow(radius: 3)
                            }
                        }
                        Button(action: fitAllSessions) {
                            Image(systemName: "mappin.and.ellipse").font(.title2).foregroundColor(accentPinColor).padding(12)
                                .background(AppColors.panelTint).clipShape(Circle()).shadow(radius: 3)
                        }
                    }
                    .padding(30)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            locationManager.requestPermissions()
            loadAndCluster()
        }
        .onChange(of: locationManager.lastLocation) { newLocation in
            guard let coord = newLocation?.coordinate ?? locationManager.effectiveCoordinate, !didCenterOnUser else { return }
            region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            didCenterOnUser = true
        }
        .sheet(item: $selectedCluster) { cluster in
            SessionListView(cluster: cluster)
        }
    }

    // MARK: - Logic Functions
    private func centerOnUser() {
        guard let coord = locationManager.effectiveCoordinate else { return }
        withAnimation { region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)) }
    }

    private func fitAllSessions() {
        guard !clusters.isEmpty else { return }
        let latitudes = clusters.map { $0.coordinate.latitude }; let longitudes = clusters.map { $0.coordinate.longitude }
        let minLat = latitudes.min() ?? 6.9271; let maxLat = latitudes.max() ?? 6.9271
        let minLon = longitudes.min() ?? 79.8612; let maxLon = longitudes.max() ?? 79.8612
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2.0, longitude: (minLon + maxLon) / 2.0)
        let latDelta = max(abs(maxLat - minLat) * 1.5, 0.1); let lonDelta = max(abs(maxLon - minLon) * 1.5, 0.1)
        withAnimation { region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)) }
    }

    private func sessionsForUserLocation() -> [GameSession] {
        guard let userCoord = locationManager.effectiveCoordinate else { return [] }
        let allSessions = sessionManager.fetchAll()
        let userLatRounded = round(userCoord.latitude * 1000) / 1000; let userLonRounded = round(userCoord.longitude * 1000) / 1000
        return allSessions.filter { session in
            round(session.latitude * 1000) / 1000 == userLatRounded && round(session.longitude * 1000) / 1000 == userLonRounded
        }
    }

    private func loadAndCluster() {
        let allSessions = sessionManager.fetchAll()
        let grouped = Dictionary(grouping: allSessions) { "\(round($0.latitude * 1000)/1000),\(round($0.longitude * 1000)/1000)" }
        clusters = grouped.map { _, sessions in SessionCluster(coordinate: sessions[0].coordinate, sessions: sessions) }
        if !didCenterOnUser {
            if let userCoord = locationManager.effectiveCoordinate {
                region = MKCoordinateRegion(center: userCoord, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                didCenterOnUser = true
            } else if !clusters.isEmpty { fitAllSessions() }
        }
    }
}

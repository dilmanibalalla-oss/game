import Foundation
import CoreLocation

struct GameSession: Codable, Identifiable {
    var id: UUID = UUID()
    var mode: String
    var score: Int
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// Helper to group sessions by location
struct SessionCluster: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let sessions: [GameSession]
}

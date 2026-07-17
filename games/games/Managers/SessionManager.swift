import Foundation

class SessionManager {
    private let key = "saved_game_sessions"
    
    func save(_ session: GameSession) {
        var sessions = fetchAll()
        sessions.append(session)
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func fetchAll() -> [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([GameSession].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func resetAllStats() {
        UserDefaults.standard.removeObject(forKey: key)
        HighScoreKeys.resetAll()
    }
    func generateGridCoordinates() -> (lat: Double, lon: Double) {
        
        let latGrid = stride(from: 6.7, through: 7.1, by: 0.05).map { $0 }
        let lonGrid = stride(from: 79.6, through: 80.1, by: 0.05).map { $0 }
        let lat = latGrid.randomElement() ?? 6.9271
        let lon = lonGrid.randomElement() ?? 79.8612
        return (lat + Double.random(in: -0.01...0.01), lon + Double.random(in: -0.01...0.01))
    }
}

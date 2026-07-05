// Managers/SessionManager.swift
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
    func generateGridCoordinates() -> (lat: Double, lon: Double) {
        // Defines a 10x10 grid (steps of 10)
        let grid = stride(from: 10.0, through: 90.0, by: 10.0).map { $0 }
        let lat = grid.randomElement() ?? 50.0
        let lon = grid.randomElement() ?? 50.0
        // Add small random jitter so they aren't perfectly aligned
        return (lat + Double.random(in: -3...3), lon + Double.random(in: -3...3))
    }
}

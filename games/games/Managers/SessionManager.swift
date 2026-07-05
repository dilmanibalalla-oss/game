// Managers/SessionManager.swift
import Foundation

class SessionManager {
    private let key = "saved_game_sessions"
    
    // Note: This must be an instance method
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
}

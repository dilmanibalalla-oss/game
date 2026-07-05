//
//  GameSession.swift
//  games
//
//  Created by student5 on 2026-07-05.
//

import Foundation
struct GameSession: Codable, Identifiable {
    var id: UUID = UUID()
    var mode: String
    var score: Int
    var timestamp: Date
    var latitude: Double
    var longitude: Double
}


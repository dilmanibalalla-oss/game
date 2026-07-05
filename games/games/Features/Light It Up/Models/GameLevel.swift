import SwiftUI

struct GameLevel {
    let levelNumber: Int
    let roundNumber: Int
    let cardCount: Int
    let litDuration: TimeInterval
    let columns: [GridItem]
    let countToLight: Int
    let activeColorsCount: Int
    
    static func config(elapsedTime: TimeInterval, round: Int) -> GameLevel {
        let level: Int = min(4, Int(elapsedTime / 15) + 1)
        
        let cards: Int
        let baseDuration: TimeInterval
        let toLight: Int
        
        switch level {
        case 1: cards = 3; baseDuration = 1.5; toLight = 1
        case 2: cards = 4; baseDuration = 1.2; toLight = 1
        case 3: cards = 6; baseDuration = 1.0; toLight = 1
        default: cards = 9; baseDuration = 0.8; toLight = 2
        }
        
    
        let finalDuration = max(0.2, baseDuration - (Double(round - 1) * 0.1))
        let colors = min(3, round)
        
        return GameLevel(
            levelNumber: level,
            roundNumber: round,
            cardCount: cards,
            litDuration: finalDuration,
            columns: Array(repeating: GridItem(.flexible()), count: (cards > 4 ? 3 : 2)),
            countToLight: toLight,
            activeColorsCount: colors
        )
    }
}


import SwiftUI

struct GameLevel {
    let levelNumber: Int
    let cardCount: Int
    let litDuration: TimeInterval
    let columns: [GridItem]
    let countToLight: Int
    
    static func config(forScore score: Int) -> GameLevel {
        let level = (score / 100) + 1
        
        let calculatedCards = min(12, 2 + level)
        // Faster lighting: reduces duration by 0.15s per level, capped at 0.2s
        let calculatedDuration = max(0.2, 1.5 - (Double(level) * 0.15))
        
        let columnCount = (calculatedCards <= 4) ? 2 : 3
        let columns = Array(repeating: GridItem(.flexible()), count: columnCount)
        let countToLight = level >= 5 ? 3 : (level >= 3 ? 2 : 1)
        
        return GameLevel(
            levelNumber: level,
            cardCount: calculatedCards,
            litDuration: calculatedDuration,
            columns: columns,
            countToLight: countToLight
        )
    }
}

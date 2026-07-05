import SwiftUI

struct GameLevel {
    let levelNumber: Int
    let roundNumber: Int
    let cardCount: Int
    let litDuration: TimeInterval
    let columns: [GridItem]
    let countToLight: Int
    let activeColorsCount: Int
    
    static func config(level: Int, round: Int) -> GameLevel {
        let calculatedCards = min(12, 3 + (level * 2))
        
        let calculatedDuration = max(0.25, 1.5 - (Double(level) * 0.1) - (Double(round) * 0.15))
        
        let columnCount = (calculatedCards <= 4) ? 2 : 3
        let columns = Array(repeating: GridItem(.flexible()), count: columnCount)
        
        let countToLight = min(4, round)
        
        let colors = min(6, 1 + level)
        
        return GameLevel(
            levelNumber: level,
            roundNumber: round,
            cardCount: calculatedCards,
            litDuration: calculatedDuration,
            columns: columns,
            countToLight: countToLight,
            activeColorsCount: colors
        )
    }
}

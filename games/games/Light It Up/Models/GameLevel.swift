import SwiftUI

struct GameLevel {
    let levelNumber: Int
    let cardCount: Int
    let litDuration: TimeInterval
    let columns: [GridItem]
    let countToLight: Int
    
    /// Generates game parameters dynamically on the fly based on elapsed time.
    static func config(forTimeElapsed timeElapsed: TimeInterval) -> GameLevel {
    
        let level = Int(timeElapsed / 15.0) + 1
        
        
        let calculatedCards = min(12, 2 + level)
        
        
        let calculatedDuration = max(0.4, 1.65 - (Double(level) * 0.15))
        
      
        let columnCount = (calculatedCards == 4 || calculatedCards == 8) ? 2 : 3
        let columns = Array(repeating: GridItem(.flexible()), count: columnCount)
        let countToLight = level >= 4 ? 2 : 1
        
        return GameLevel(
            levelNumber: level,
            cardCount: calculatedCards,
            litDuration: calculatedDuration,
            columns: columns,
            countToLight: countToLight
        )
    }
}


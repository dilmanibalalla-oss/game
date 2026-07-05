import Foundation

enum HighScoreKeys {
    static let tapFrenzy = "tapFrenzyHighScore"
    static let lightItUp = "lightItUpHighScore"
    static let quiz = "quizHighScore"
    private static let legacyQuiz = "QuizHighScore"
    
    static func migrateIfNeeded() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: quiz) == nil,
           defaults.object(forKey: legacyQuiz) != nil {
            defaults.set(defaults.integer(forKey: legacyQuiz), forKey: quiz)
            defaults.removeObject(forKey: legacyQuiz)
        }
    }
    
    static func resetAll() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: tapFrenzy)
        defaults.removeObject(forKey: lightItUp)
        defaults.removeObject(forKey: quiz)
        defaults.removeObject(forKey: legacyQuiz)
    }
}

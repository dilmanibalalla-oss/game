import Foundation

struct QuizResponse: Codable {
    let response_code: Int
    let results: [Question]
}
struct Question: Codable, Identifiable {
    let id = UUID()
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    

    var allAnswers: [String] {
        incorrect_answers + [correct_answer]
    }
}

public enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case easy
    case medium
    case hard

    public var id: String { rawValue }
}

public struct QuizCategory: Identifiable, Codable, Hashable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    public static let all: [QuizCategory] = [
        QuizCategory(id: 9, name: "General Knowledge"),
        QuizCategory(id: 10, name: "Entertainment: Books"),
        QuizCategory(id: 11, name: "Entertainment: Film"),
        QuizCategory(id: 12, name: "Entertainment: Music"),
        QuizCategory(id: 14, name: "Entertainment: Television"),
        QuizCategory(id: 15, name: "Entertainment: Video Games"),
        QuizCategory(id: 17, name: "Science & Nature"),
        QuizCategory(id: 18, name: "Science: Computers"),
        QuizCategory(id: 19, name: "Science: Mathematics"),
        QuizCategory(id: 21, name: "Sports"),
        QuizCategory(id: 22, name: "Geography"),
        QuizCategory(id: 23, name: "History"),
        QuizCategory(id: 24, name: "Politics"),
        QuizCategory(id: 27, name: "Animals"),
        QuizCategory(id: 28, name: "Vehicles")
    ]
}

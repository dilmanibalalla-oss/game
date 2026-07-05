import Foundation

class QuizService {
    
    func fetchQuestions(amount: Int = 10,
                        category: Int? = nil,
                        difficulty: String? = nil,
                        type: String = "multiple") async throws -> [Question] {
        let timestamp = Int(Date().timeIntervalSince1970)

        var components = URLComponents(string: "https://opentdb.com/api.php")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "amount", value: String(amount)),
            URLQueryItem(name: "type", value: type),
            URLQueryItem(name: "t", value: String(timestamp))
        ]
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: String(category)))
        }
        if let difficulty = difficulty?.lowercased(), ["easy","medium","hard"].contains(difficulty) {
            queryItems.append(URLQueryItem(name: "difficulty", value: difficulty))
        }
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(QuizResponse.self, from: data)

        if decoded.response_code != 0 {
            throw NSError(domain: "QuizService", code: decoded.response_code, userInfo: [NSLocalizedDescriptionKey: "API returned error code: \(decoded.response_code)"])
        }

        return decoded.results
    }
}

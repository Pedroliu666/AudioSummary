import Foundation
import FirebaseStorage
// Structs to model the relevant parts of the JSON response
struct ChatCompletionResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}

class NetworkingService {

    static let shared = NetworkingService()
    
    private init() {}
    
    let apiKey = "aeccbbf1890946b4810d4883c22caa3d"
    let apiUrlString = "https://api.umgpt.umich.edu/azure-openai-api/openai/deployments/gpt-35-turbo/chat/completions?api-version=2023-05-15"
    let organization = "182001"
    
    func fetchSummary(for message: String, completion: @escaping (Result<String, Error>) -> Void) {
        let json: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful bot"],
                ["role": "user", "content": message]
            ],
            "max_tokens": 512,
            "temperature": 0,
            "frequency_penalty": 0,
            "top_p": 0.95
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json),
              let apiUrl = URL(string: apiUrlString) else {
            print("Error creating JSON data or URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(organization, forHTTPHeaderField: "OpenAI-Organization")
        request.addValue(apiKey, forHTTPHeaderField: "api-key")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    do {
                        // Decode the JSON data into ChatCompletionResponse
                        let decoder = JSONDecoder()
                        let chatResponse = try decoder.decode(ChatCompletionResponse.self, from: data)
                        
                        // Assuming you want to return the content of the first choice's message
                        if let firstChoiceContent = chatResponse.choices.first?.message.content {
                            completion(.success(firstChoiceContent))
                        } else {
                            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No content found"])))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    print("HTTP Request Failed")
                    let httpResponse = response as? HTTPURLResponse
                    completion(.failure(NSError(domain: "", code: httpResponse?.statusCode ?? 500, userInfo: nil)))
                }
        }
        
        
        task.resume()
    }
}

//
//  OllamaTranslationRepository.swift
//  Medium_UI
//
//  Created by Shahanul Haque on 12/21/24.
//

import Foundation
// Repository Implementation (Dependency Inversion Principle)
class OllamaTranslationRepository: TranslationService {
    private let baseURL = "http://192.168.0.213:11434/api/generate"
    private let model = "gemma2:latest"
    private var currentTask: Task<Void, Error>?
    
    func cancelTranslation() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    func translate(text: String, from: Language, to: Language) async throws -> AsyncStream<String> {
        print("translate called with, \(from), \(to)")
        return AsyncStream { continuation in
            currentTask = Task {
                let prompt = """
                Translate the following text from \(from.rawValue) to \(to.rawValue):
                "\(text)"
                Only provide the translation, no explanations.
                """
                
                let body: [String: Any] = [
                    "model": model,
                    "prompt": prompt,
                    "stream": true
                ]
                
                guard let url = URL(string: baseURL),
                      let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
                    continuation.finish()
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                do {
                    let (stream, _) = try await URLSession.shared.bytes(for: request)
                    
                    for try await line in stream.lines {
                        if Task.isCancelled {
                            break
                        }
                        
                        guard let data = line.data(using: .utf8),
                              let response = try? JSONDecoder().decode(OllamaResponse.self, from: data) else {
                            continue
                        }
                        continuation.yield(response.response)
                    }
                    continuation.finish()
                } catch {
                    if !Task.isCancelled {
                        print("Translation error: \(error)")
                    }
                    continuation.finish()
                }
            }
        }
    }
}

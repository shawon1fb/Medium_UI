//
//  OllamaTranslationRepository.swift
//  Medium_UI
//
//  Created by Shahanul Haque on 12/21/24.
//

import Foundation
import Foundation

import Foundation

class OllamaTranslationRepository: TranslationService {
    private let baseURL = "http://192.168.0.213:11434/api/generate"
    private let model = "gemma2:latest"
    private var currentTask: Task<Void, Error>?
    
    // Configuration
    private let maxChunkSize = 2000
    private let maxConcurrentRequests = 2  // Limit concurrent API calls
    private let requestDelay: TimeInterval = 0.5  // Add delay between requests
    
    // Semaphore to control concurrent API calls
    private let requestSemaphore = DispatchSemaphore(value: 2)
    
    // URLSession configuration for better resource management
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.httpMaximumConnectionsPerHost = 2
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()
    
    func cancelTranslation() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    private func splitTextIntoSentences(_ text: String) -> [String] {
        let terminators = [".", "!", "?", "。", "！", "？"]
        let paragraphs = text.components(separatedBy: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        var sentences: [String] = []
        var currentSentence = ""
        
        for paragraph in paragraphs {
            var remainingText = paragraph
            
            while !remainingText.isEmpty {
                var terminatorIndex = remainingText.endIndex
                var foundTerminator = false
                
                for terminator in terminators {
                    if let index = remainingText.range(of: terminator)?.upperBound {
                        if index < terminatorIndex {
                            terminatorIndex = index
                            foundTerminator = true
                        }
                    }
                }
                
                if foundTerminator {
                    let sentence = String(remainingText[..<terminatorIndex])
                    remainingText = String(remainingText[terminatorIndex...])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !currentSentence.isEmpty {
                        currentSentence += " "
                    }
                    currentSentence += sentence
                    
                    if currentSentence.count >= maxChunkSize {
                        sentences.append(currentSentence.trimmingCharacters(in: .whitespacesAndNewlines))
                        currentSentence = ""
                    }
                } else {
                    if !remainingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        if !currentSentence.isEmpty {
                            currentSentence += " "
                        }
                        currentSentence += remainingText
                    }
                    break
                }
            }
            
            if !currentSentence.isEmpty {
                sentences.append(currentSentence.trimmingCharacters(in: .whitespacesAndNewlines))
                currentSentence = ""
            }
        }
        
        if !currentSentence.isEmpty {
            sentences.append(currentSentence.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        return sentences.filter { !$0.isEmpty }
    }
    
    private func createRequest(text: String, from: Language, to: Language) throws -> URLRequest {
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
            throw NSError(domain: "TranslationError", code: -1, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func translateChunk(text: String, from: Language, to: Language) async throws -> AsyncStream<String> {
        return AsyncStream { continuation in
            Task {
                // Wait for semaphore
                let _ = requestSemaphore.wait(timeout: .now() + 30)
                defer { requestSemaphore.signal() }
                
                do {
                    let request = try createRequest(text: text, from: from, to: to)
                    let (stream, _) = try await urlSession.bytes(for: request)
                    
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
                    
                    // Add delay between requests
                    try await Task.sleep(nanoseconds: UInt64(requestDelay * 1_000_000_000))
                    
                } catch {
                    if !Task.isCancelled {
                        print("Translation error: \(error)")
                    }
                }
                continuation.finish()
            }
        }
    }
    
    func translate(text: String, from: Language, to: Language) async throws -> AsyncStream<String> {
        return AsyncStream { continuation in
            currentTask = Task {
                let sentences = splitTextIntoSentences(text)
                var isFirstChunk = true
                
                // Process chunks in batches to reduce memory usage
                for chunk in stride(from: 0, to: sentences.count, by: maxConcurrentRequests) {
                    if Task.isCancelled { break }
                    
                    let endIndex = min(chunk + maxConcurrentRequests, sentences.count)
                    let batch = sentences[chunk..<endIndex]
                    
                    // Process batch concurrently
                    try await withThrowingTaskGroup(of: (Int, String).self) { group in
                        for (index, sentence) in batch.enumerated() {
                            group.addTask {
                                var result = ""
                                let stream = try await self.translateChunk(text: sentence, from: from, to: to)
                                for try await translation in stream {
                                    result += translation
                                }
                                return (chunk + index, result)
                            }
                        }
                        
                        // Collect and yield results in order
                        var batchResults: [(Int, String)] = []
                        for try await result in group {
                            batchResults.append(result)
                        }
                        
                        for (_, translation) in batchResults.sorted(by: { $0.0 < $1.0 }) {
                            if !isFirstChunk {
                                continuation.yield(" ")
                            }
                            isFirstChunk = false
                            continuation.yield(translation)
                        }
                    }
                }
                
                continuation.finish()
            }
        }
    }
}

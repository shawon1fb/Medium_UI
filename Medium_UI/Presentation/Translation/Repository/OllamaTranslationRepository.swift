//
//  OllamaTranslationRepository.swift
//  Medium_UI
//
//  Created by Shahanul Haque on 12/21/24.
//
import Foundation

struct OllamaRestResponse: Codable {
    let response: String
    let done: Bool
}

actor OllamaTranslationRepository: TranslationService {
    private let baseURL = "http://192.168.0.213:11434/api/generate"
    private let model = "gemma2:latest"
    private var currentTask: Task<Void, Error>?
    
    // Configuration
    private let maxChunkSize = 2000
    private let maxConcurrentRequests = 2
    private let requestDelay: TimeInterval = 0.3
    
    // Optimized URLSession configuration
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.httpMaximumConnectionsPerHost = 2
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()
    
    // Active translations tracking
    private var activeTranslations: Set<UUID> = []
    
    nonisolated func cancelTranslation() {
        Task { await _cancelTranslation() }
    }
    
    private func _cancelTranslation() {
        currentTask?.cancel()
        currentTask = nil
        activeTranslations.removeAll()
    }
    
    private func trackTranslation(_ id: UUID) -> Bool {
        guard !activeTranslations.contains(id) else { return false }
        activeTranslations.insert(id)
        return true
    }
    
    private func untrackTranslation(_ id: UUID) {
        activeTranslations.remove(id)
    }
    
    private nonisolated func splitTextIntoSentences(_ text: String) -> [String] {
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
    
    private nonisolated func translateChunk(text: String, from: Language, to: Language) async throws -> String {
        let prompt = """
        Translate the following text from \(from.rawValue) to \(to.rawValue):
        "\(text)"
        Only provide the translation, no explanations.
        """
        
        let body: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "stream": false
        ]
        
        guard let url = URL(string: baseURL),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            throw NSError(domain: "TranslationError", code: -1, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await urlSession.data(for: request)
        let response = try JSONDecoder().decode(OllamaRestResponse.self, from: data)
        
        // Add delay between requests
        try await Task.sleep(nanoseconds: UInt64(requestDelay * 1_000_000_000))
        
        return response.response
    }
    
    nonisolated func translate(text: String, from: Language, to: Language) async throws -> AsyncStream<String> {
        let translationId = UUID()
        
        return AsyncStream { continuation in
            Task {
                // Check if we can start this translation
                guard await trackTranslation(translationId) else {
                    continuation.finish()
                    return
                }
                
                defer {
                    Task {
                        await untrackTranslation(translationId)
                    }
                }
                
                do {
                    let sentences = splitTextIntoSentences(text)
                    var isFirstChunk = true
                    
                    // Process chunks in batches
                    for chunk in stride(from: 0, to: sentences.count, by: maxConcurrentRequests) {
                        if Task.isCancelled { break }
                        
                        let endIndex = min(chunk + maxConcurrentRequests, sentences.count)
                        let batch = sentences[chunk..<endIndex]
                        
                        // Process batch concurrently
                        try await withThrowingTaskGroup(of: (Int, String).self) { group in
                            for (index, sentence) in batch.enumerated() {
                                group.addTask {
                                    let translation = try await self.translateChunk(
                                        text: sentence,
                                        from: from,
                                        to: to
                                    )
                                    return (chunk + index, translation)
                                }
                            }
                            
                            // Collect and yield results in order
                            var batchResults: [(Int, String)] = []
                            for try await result in group {
                                batchResults.append(result)
                            }
                            
                            for (_, translation) in batchResults.sorted(by: { $0.0 < $1.0 }) {
                                if Task.isCancelled { break }
                                
                                if !isFirstChunk {
                                    continuation.yield(" ")
                                }
                                isFirstChunk = false
                                continuation.yield(translation)
                            }
                        }
                    }
                } catch {
                    print("Translation error: \(error)")
                }
                continuation.finish()
            }
        }
    }
}

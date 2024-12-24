import Foundation

struct OllamaStreamResponse: Codable {
    let response: String
    let done: Bool
}

actor OllamaTranslationRepository: TranslationService {
    private let baseURL = "http://192.168.0.213:11434/api/generate"
    private let model = "gemma2:latest"
    private var currentTask: Task<Void, Error>?
    
    // Optimized configuration
    private let maxTokensPerRequest = 512
    private let concurrentRequestLimit = 3
    private let requestDelay: TimeInterval = 0.1
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.httpMaximumConnectionsPerHost = 1
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.networkServiceType = .responsiveData
        config.shouldUseExtendedBackgroundIdleMode = true
        config.waitsForConnectivity = true
        return URLSession(configuration: config,
                         delegate: nil,
                         delegateQueue: .main)
    }()
    
    private var activeTranslationId: UUID?
    
    func cancelTranslation() async {
        currentTask?.cancel()
        currentTask = nil
        activeTranslationId = nil
    }
    
    private func canStartTranslation(_ id: UUID) -> Bool {
        guard activeTranslationId == nil else { return false }
        activeTranslationId = id
        return true
    }
    
    private func endTranslation(_ id: UUID) {
        if activeTranslationId == id {
            activeTranslationId = nil
        }
    }
    
    private func splitTextIntoChunks(_ text: String) -> [String] {
        let approximateTokenCount = text.count / 4 // Rough estimation
        let chunkSize = min(maxTokensPerRequest * 4, 1000) // Conservative chunk size
        
        return text.components(separatedBy: ".")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .reduce(into: [String]()) { chunks, sentence in
                if let lastChunk = chunks.last,
                   lastChunk.count + sentence.count < chunkSize {
                    chunks[chunks.count - 1] = lastChunk + "." + sentence
                } else {
                    chunks.append(sentence)
                }
            }
    }
    
    private nonisolated func streamTranslation(
        for request: URLRequest
    ) async throws -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let (bytes, _) = try await urlSession.bytes(for: request)
                    for try await line in bytes.lines {
                        guard !line.isEmpty else { continue }
                        guard let data = line.data(using: .utf8),
                              let response = try? JSONDecoder().decode(OllamaStreamResponse.self, from: data)
                        else { continue }
                        
                        continuation.yield(response.response)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private nonisolated func createTranslationRequest(
        chunk: String,
        from: Language,
        to: Language
    ) throws -> URLRequest {
        let prompt = """
        You are a precise translator. Task: Translate this \(from.rawValue) text to \(to.rawValue) keeping style and tone:
        Text: "\(chunk)"
        Rules:
        - Maintain formatting
        - Keep numbers and proper names unchanged
        - No explanations
        Translation:
        """
        
        let body: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "stream": true
        ]
        
        guard let url = URL(string: baseURL),
              let jsonData = try? JSONSerialization.data(withJSONObject: body)
        else {
            throw NSError(domain: "TranslationError", code: -1)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func translate(
        text: String,
        from: Language,
        to: Language
    ) async throws -> AsyncStream<String> {
        let translationId = UUID()
        
        return AsyncStream { continuation in
            currentTask = Task {
                guard canStartTranslation(translationId) else {
                    continuation.finish()
                    return
                }
                
                defer { endTranslation(translationId) }
                
                do {
                    let chunks = splitTextIntoChunks(text)
                    var isFirstChunk = true
                    
                    // Process chunks with controlled concurrency
                    for chunk in chunks {
                        if Task.isCancelled { break }
                        
                        if !isFirstChunk {
                            continuation.yield(" ")
                        }
                        isFirstChunk = false
                        
                        let request = try createTranslationRequest(chunk: chunk, from: from, to: to)
                        for try await part in try await streamTranslation(for: request) {
                            continuation.yield(part)
                        }
                        
                        try await Task.sleep(nanoseconds: UInt64(requestDelay * 1_000_000_000))
                    }
                } catch {
                    print("Translation error: \(error)")
                }
                continuation.finish()
            }
        }
    }
}

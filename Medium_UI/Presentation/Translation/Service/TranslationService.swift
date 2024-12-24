//
//  TranslationService.swift
//  Medium_UI
//
//  Created by Shahanul Haque on 12/21/24.
//

import Foundation
// Translation Protocol (Interface Segregation Principle)
protocol TranslationService {
    func translate(text: String, from: Language, to: Language) async throws -> AsyncStream<String>
    func cancelTranslation() async // Add cancellation method
}
class MockTranslationService: TranslationService {
    private var continuations: [UUID: AsyncStream<String>.Continuation] = [:]
    private let mockDelay: TimeInterval
    private var isCancelled = false
    
    init(mockDelay: TimeInterval = 0.1) {
        self.mockDelay = mockDelay
    }
    
    func translate(text: String, from: Language, to: Language) async throws -> AsyncStream<String> {
        // Reset cancellation state
        isCancelled = false
        
        return AsyncStream<String> { [weak self] continuation in
            guard let self = self else { return }
            
            // Create unique identifier for this translation
            let translationId = UUID()
            self.continuations[translationId] = continuation
            
            // Create background task for mock translation
            Task {
                // Simulate word-by-word translation
                let words = text.components(separatedBy: " ")
                
                for word in words {
                    if self.isCancelled {
                        continuation.finish()
                        break
                    }
                    
                    // Simulate translation delay
                    try? await Task.sleep(nanoseconds: UInt64(self.mockDelay * 1_000_000_000))
                    
                    if !self.isCancelled {
                        // Mock translation by adding prefix based on target language
                        let translatedWord = self.mockTranslateWord(word, to: to)
                        continuation.yield(translatedWord + " ")
                    }
                }
                
                if !self.isCancelled {
                    continuation.finish()
                }
                
                // Remove continuation after completion
                self.continuations.removeValue(forKey: translationId)
            }
        }
    }
    
    func cancelTranslation() {
        isCancelled = true
        // Finish all active continuations
        continuations.values.forEach { continuation in
            continuation.finish()
        }
        continuations.removeAll()
    }
    
    // Helper method to simulate translation based on target language
    private func mockTranslateWord(_ word: String, to language: Language) -> String {
        switch language {
            case .bangla:
                return "বা_" + word
            case .english:
                return word
            // Add more cases as needed
        }
    }
    
    // Optional: Add methods for testing
    func isCurrentlyCancelled() -> Bool {
        return isCancelled
    }
    
    func activeTranslationCount() -> Int {
        return continuations.count
    }
}

//
//  TranslationViewModel.swift
//  Medium_UI
//
//  Created by Shahanul Haque on 12/21/24.
//

import SwiftUI
import Combine
// ViewModel (Single Responsibility Principle)
@MainActor
class TranslationViewModel: ObservableObject {
    private let translationService: TranslationService
    
    @Published var originalText: String = ""
    @Published var translatedText: String = ""
    @Published var selectedLanguage: Language = .bangla
    @Published var isTranslating: Bool = false
    
    init(translationService: TranslationService) {
        self.translationService = translationService
    }
    
    func stopTranslation() {
        translationService.cancelTranslation()
        isTranslating = false
    }
    
    func translate(text: String) {
        guard !text.isEmpty else { return }
        
        Task {
            isTranslating = true
            translatedText = ""
            
            do {
                let stream = try await translationService.translate(
                    text: text,
                    from: .english,
                    to: selectedLanguage
                )
                
                for await translation in stream {
                    if Task.isCancelled {
                        break
                    }
                    print("Translation: \(translation)")
                    translatedText += translation
                }
            } catch {
                // Handle error appropriately
                print("Translation error: \(error)")
            }
            
            isTranslating = false
        }
    }
}

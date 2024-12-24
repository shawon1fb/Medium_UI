//
//  TranslationViewModel.swift
//  Medium_UI
//
//  Created by Shahanul Haque on 12/21/24.
//

import SwiftUI
import Combine
import EasyX
import XSwiftUI

final class TranslationViewModelBindings{
    
    
    func getDependencies() -> TranslationViewModel{
        
        if let viewModel = try? DIContainer.shared.resolve(TranslationViewModel.self){
            return viewModel
        }
        
        let ollamaService = OllamaTranslationRepository()
//        let ollamaService = MockTranslationService()
        let viewModel = TranslationViewModel(
            translationService: ollamaService
        )
         DIContainer.shared.register(TranslationViewModel.self, factory: { _ in viewModel})
        return viewModel
        
    }
}

class TranslationViewModel: ObservableObject {
    private let translationService: TranslationService
    private var currentTask: Task<Void, Never>?
    
    @Published var originalText: String = ""
    @Published var translatedText: String = ""
    @Published var selectedLanguage: Language = .bangla
    @Published var isTranslating: Bool = false
    
    init(translationService: TranslationService) {
        self.translationService = translationService
    }
    
    func stopTranslation() {
            currentTask?.cancel()
            currentTask = nil
            translationService.cancelTranslation()
            
            Task { @MainActor in
                isTranslating = false
            }
        }

    @MainActor
    func translate(text: String) {
        guard !text.isEmpty else {
            translatedText = ""
            return
        }
        
        // Only stop ongoing translation if the new text is different
        if isTranslating && originalText != text {
            stopTranslation()
        } else if isTranslating && originalText == text {
            // Continue with current translation
            return
        }
        
        // Create and store new translation task
        currentTask = Task {
            isTranslating = true
            translatedText = ""
            originalText = text
            
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
                    translatedText += translation
                }
            } catch {
                // Handle error appropriately
                print("Translation error: \(error)")
                // Optionally set an error state here
            }
            
            if !Task.isCancelled {
                isTranslating = false
            }
        }
    }
}

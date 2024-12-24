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
        let viewModel = TranslationViewModel(
            translationService: ollamaService
        )
         DIContainer.shared.register(TranslationViewModel.self, factory: { _ in viewModel})
        return viewModel
        
    }
}


class TranslationViewModel: ObservableObject {
    private let translationService: TranslationService
    
    @Published var originalText: String = ""
    @Published var translatedText: String = ""
    @Published var selectedLanguage: Language = .bangla
    @Published var isTranslating: Bool = false
    
    init(translationService: TranslationService) {
        self.translationService = translationService
    }
    
    @MainActor
    func stopTranslation() {
        translationService.cancelTranslation()
        isTranslating = false
    }

    @MainActor
    func translate(text: String) {
        guard text.isEmpty == false else { return }
        
        guard isTranslating != true && originalText != text else { return }
        
        Task {
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

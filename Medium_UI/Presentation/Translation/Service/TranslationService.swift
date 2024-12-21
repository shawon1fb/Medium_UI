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
    func cancelTranslation() // Add cancellation method
}

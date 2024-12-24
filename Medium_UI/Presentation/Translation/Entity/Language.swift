//
//  Language.swift
//  Medium_UI
//
//  Created by Shahanul Haque on 12/21/24.
//

// Entity
enum Language: String, CaseIterable {
    case english = "English"
    case bangla = "বাংলা"
    
    var code: String {
        switch self {
        case .english: return "en"
        case .bangla: return "bn"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .bangla: return "🇧🇩"
        }
    }
}

// Conformance to CustomStringConvertible for the description property
extension Language: CustomStringConvertible {
    var description: String {
        "\(flag) \(rawValue) (\(code))"
    }
}

//
//  PostUIModels.swift
//  Medium_UI
//
//  Created by shahanul on 12/16/24.
//
import Foundation

struct ParsedParagraph: Identifiable {
    var id: String { original.id.uuidString }
    let original: Paragraph
    let attributedText: AttributedString?
    let isHighlighted: Bool
}

struct PostTag: Codable {
    let displayTitle: String
}

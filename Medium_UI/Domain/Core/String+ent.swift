//
//  String+ent.swift
//  Medium_UI
//
//  Created by shahanul on 11/19/24.
//

import Foundation

import SwiftUI

extension AttributedString {
   func index(_ startIndex: AttributedString.Index, offsetByUTF8 offset: Int) -> AttributedString.Index? {
       var currentIndex = startIndex
       for _ in 0..<offset {
           currentIndex = self.characters.index(after: currentIndex)
       }
       return currentIndex
   }
}
private func parseMarkups(text: String, markups: [Markup], isHighlighted: Bool) -> AttributedString {
    var attributedString = AttributedString(text)
    
    // Sort markups by start position to handle nested markups correctly
    let sortedMarkups = markups.sorted { $0.start < $1.start }
    
    for markup in sortedMarkups {
        guard markup.start >= 0,
              markup.end <= text.utf8.count,
              let startIndex = attributedString.index(attributedString.startIndex, offsetByUTF8: markup.start),
              let endIndex = attributedString.index(attributedString.startIndex, offsetByUTF8: markup.end)
        else {
            continue
        }
        
        let range = startIndex..<endIndex
        
        switch markup.type {
        case .strong:
            attributedString[range].font = Font.body.bold()
        case .em:
            attributedString[range].font = Font.body.italic()
        case .link:
            if let href = markup.href, let url = URL(string: href) {
                attributedString[range].foregroundColor = Color.accentColor
                attributedString[range].link = url
            }
        case .code:
            attributedString[range].font = Font.body.monospaced()
            attributedString[range].backgroundColor = Color(NSColor.windowBackgroundColor).opacity(0.3)
        case .strike:
            attributedString[range].strikethroughStyle = .single
        }
    }
    
    if isHighlighted {
        let startIndex = attributedString.startIndex
        let endIndex = attributedString.endIndex
        attributedString[startIndex..<endIndex].backgroundColor = Color.yellow.opacity(0.3)
    }
    
    return attributedString
}
// MARK: - Utility Extensions

extension String {
    func percentageMatch(with other: String) -> Double {
        let str1 = self.lowercased()
        let str2 = other.lowercased()
        
        if str1 == str2 { return 100 }
        if str1.isEmpty || str2.isEmpty { return 0 }
        
        let distance = levenshteinDistance(from: str1, to: str2)
        let maxLength = Double(max(str1.count, str2.count))
        return (1.0 - Double(distance) / maxLength) * 100
    }
    
    private func levenshteinDistance(from str1: String, to str2: String) -> Int {
        let empty = Array(repeating: 0, count: str2.count + 1)
        var last = Array(0...str2.count)
        
        for (i, char1) in str1.enumerated() {
            var current = [i + 1] + empty
            
            for (j, char2) in str2.enumerated() {
                current[j + 1] = char1 == char2 ? last[j] : min(last[j], min(last[j + 1], current[j])) + 1
            }
            
            last = current
        }
        
        return last[str2.count]
    }
}

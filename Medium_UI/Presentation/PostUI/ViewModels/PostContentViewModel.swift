//
//  PostContentViewModel.swift
//  Medium_UI
//
//  Created by shahanul on 11/19/24.
//

import Foundation
import SwiftUI
import MediumCore
#if canImport(UIKit)
import UIKit
typealias FontType = UIFont
#else
import AppKit
typealias FontType = NSFont
#endif
import SwiftUI

class PostContentViewModel: ObservableObject {
    @Published var paragraphs: [ParsedParagraph] = []
    @Published var title: String = ""
    @Published var subtitle: String = ""
    let repository: MediumRepository = MediumRepository()
    @Published var previewImageId: String = ""
    @Published  var highlights: [HighlightModel] = []
    @Published var tags: [PostTag] = []
    
    @Published var hasError: String? =  nil
    
 
    
  
   
    init(){
        
    }
    
    @MainActor
    func getPostContent()async {
        do{
            hasError = nil
            let post = try await repository.getPost2()
            title = post.title
            subtitle = post.previewContent.subtitle
            previewImageId = post.previewImage.id
            
            
            highlights = post.highlights
            tags = post.tags.map({ .init(displayTitle: $0.displayTitle)})
            //paragraphs = post.content.bodyModel.paragraphs.map({ .init(original: $0, attributedText: nil, isHighlighted: false)})
            
             parseContent(post.content)
            
        }catch{
            print("error fetching post: \(error)")
            hasError = error.localizedDescription
        }
    }
    
    private func parseContent(_ content: ContentModel) {
        var processedParagraphs: [ParsedParagraph] = []
        var currentIndex = 0
        
        while currentIndex < content.bodyModel.paragraphs.count {
            let paragraph = content.bodyModel.paragraphs[currentIndex]
            
            // Skip title/subtitle/preview image in first paragraphs
            if currentIndex < 4 {
                if shouldSkipParagraph(paragraph) {
                    currentIndex += 1
                    continue
                }
            }
            
            // Handle special paragraph types
            switch paragraph.type {
            case .unorderedList, .orderedList:
                let (listParagraphs, newIndex) = processListParagraphs(from: currentIndex, paragraphs: content.bodyModel.paragraphs)
                processedParagraphs.append(contentsOf: listParagraphs)
                currentIndex = newIndex
                
            case .image where paragraph.layout == .outsetRow:
                let (imageParagraphs, newIndex) = processImageRow(from: currentIndex, paragraphs: content.bodyModel.paragraphs)
                processedParagraphs.append(contentsOf: imageParagraphs)
                currentIndex = newIndex
                
            case .preformatted:
                let (codeParagraphs, newIndex) = processCodeBlock(from: currentIndex, paragraphs: content.bodyModel.paragraphs)
                processedParagraphs.append(contentsOf: codeParagraphs)
                currentIndex = newIndex
                
            default:
                let parsedParagraph = parseSingleParagraph(paragraph)
                processedParagraphs.append(parsedParagraph)
                currentIndex += 1
            }
        }
        
        DispatchQueue.main.async {
            self.paragraphs = processedParagraphs
        }
    }
    
    private func shouldSkipParagraph(_ paragraph: Paragraph) -> Bool {
        // Skip title
        if paragraph.type == .h3 || paragraph.type == .h4 || paragraph.type == .h2 {
            if let text = paragraph.text, text.percentageMatch(with: title) > 80 {
                return true
            }
        }
        
        // Skip subtitle
        if paragraph.type == .h4 || paragraph.type == .paragraph {
            if let text = paragraph.text, text.percentageMatch(with: subtitle) > 80 {
                return true
            }
        }
        
        // Skip preview image
        if paragraph.type == .image {
            if let metadata = paragraph.metadata, metadata.id == previewImageId {
                return true
            }
        }
        
        // Skip tag paragraphs
        if paragraph.type == .h4 {
            if let text = paragraph.text, tags.contains(where: { $0.displayTitle == text }) {
                return true
            }
        }
        
        return false
    }
    
    private func parseSingleParagraph(_ paragraph: Paragraph) -> ParsedParagraph {
        let isHighlighted = highlights.contains { highlight in
            highlight.paragraphs.contains { $0.name == paragraph.name }
        }
        
        var attributedText: AttributedString?
        if let text = paragraph.text {
            attributedText = parseMarkups(text: text, markups: paragraph.markups, isHighlighted: isHighlighted)
        }
        
        return ParsedParagraph(original: paragraph, attributedText: attributedText, isHighlighted: isHighlighted)
    }
   
    private func parseMarkups(text: String, markups: [Markup], isHighlighted: Bool) -> AttributedString {
        var attributedString = AttributedString(text)
        
        let sortedMarkups = markups.sorted { $0.start < $1.start }
        
        for markup in sortedMarkups {
            guard markup.start >= 0,
                  markup.end <= text.count,
                  let startIndex = attributedString.index(attributedString.startIndex, offsetByUTF8: markup.start),
                  let endIndex = attributedString.index(attributedString.startIndex, offsetByUTF8: markup.end)
            else {
                continue
            }
            
            let range = startIndex..<endIndex
            
            switch markup.type {
            case .strong:
                attributedString[range].font = .init(FontType.boldSystemFont(ofSize: FontType.systemFontSize))
            case .em:
                #if canImport(UIKit)
                attributedString[range].font = .init(FontType.italicSystemFont(ofSize: FontType.systemFontSize))
                #else
                attributedString[range].font = .init(FontType.systemFont(ofSize: FontType.systemFontSize, weight: .regular))
                #endif
            case .link:
                if let href = markup.href, let url = URL(string: href) {
                    attributedString[range].foregroundColor = Color.blue
                    attributedString[range].link = url
                }
            case .code:
                #if canImport(UIKit)
                attributedString[range].font = .init(FontType.monospacedSystemFont(ofSize: FontType.systemFontSize, weight: .regular))
                #else
                attributedString[range].font = .init(FontType.monospacedDigitSystemFont(ofSize: FontType.systemFontSize, weight: .regular))
                #endif
                attributedString[range].backgroundColor = Color.gray.opacity(0.2)
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


    
    // Helper methods for processing special paragraph types
    private func processListParagraphs(from index: Int, paragraphs: [Paragraph]) -> ([ParsedParagraph], Int) {
        var listParagraphs: [ParsedParagraph] = []
        var currentIndex = index
        let listType = paragraphs[index].type
        
        while currentIndex < paragraphs.count && paragraphs[currentIndex].type == listType {
            let parsedParagraph = parseSingleParagraph(paragraphs[currentIndex])
            listParagraphs.append(parsedParagraph)
            currentIndex += 1
        }
        
        return (listParagraphs, currentIndex)
    }
    
    private func processImageRow(from index: Int, paragraphs: [Paragraph]) -> ([ParsedParagraph], Int) {
        var imageParagraphs: [ParsedParagraph] = []
        var currentIndex = index
        
        while currentIndex < paragraphs.count {
            let paragraph = paragraphs[currentIndex]
            if paragraph.type == .image && (paragraph.layout == .outsetRow || paragraph.layout == .outsetRowContinue) {
                let parsedParagraph = parseSingleParagraph(paragraph)
                imageParagraphs.append(parsedParagraph)
                currentIndex += 1
            } else {
                break
            }
        }
        
        return (imageParagraphs, currentIndex)
    }
    
    private func processCodeBlock(from index: Int, paragraphs: [Paragraph]) -> ([ParsedParagraph], Int) {
        var codeParagraphs: [ParsedParagraph] = []
        var currentIndex = index
        
        while currentIndex < paragraphs.count && paragraphs[currentIndex].type == .preformatted {
            let parsedParagraph = parseSingleParagraph(paragraphs[currentIndex])
            codeParagraphs.append(parsedParagraph)
            currentIndex += 1
        }
        
        return (codeParagraphs, currentIndex)
    }
}

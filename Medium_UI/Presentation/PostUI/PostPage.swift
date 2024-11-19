//
//  PostPage.swift
//  Medium_UI
//
//  Created by shahanul on 11/19/24.
//

import SwiftUI
import Foundation
import AppKit

struct ParagraphView: View {
    let paragraph: PostContentViewModel.ParsedParagraph
    
    var body: some View {
        switch paragraph.original.type {
        case .h2:
            HeaderView(text: paragraph.attributedText, level: .h2)
        case .h3:
            HeaderView(text: paragraph.attributedText, level: .h3)
        case .h4:
            HeaderView(text: paragraph.attributedText, level: .h4)
        case .image:
            ImageParagraphView(paragraph: paragraph.original)
        case .paragraph:
            ParagraphTextView(attributedText: paragraph.attributedText)
        case .unorderedList:
            ListItemView(attributedText: paragraph.attributedText, isOrdered: false)
        case .orderedList:
            ListItemView(attributedText: paragraph.attributedText, isOrdered: true)
        case .preformatted:
            CodeBlockView(paragraph: paragraph.original)
        case .blockquote:
            BlockquoteView(attributedText: paragraph.attributedText)
        case .pullQuote:
            PullQuoteView(attributedText: paragraph.attributedText)
        case .mixtapeEmbed:
            MixtapeEmbedView(paragraph: paragraph.original)
        case .iframe:
            IframeView(paragraph: paragraph.original)
        }
    }
}

struct HeaderView: View {
    let text: AttributedString?
    let level: HeaderLevel
    
    enum HeaderLevel {
        case h2, h3, h4
        
        var font: Font {
            switch self {
            case .h2: return .title
            case .h3: return .title2
            case .h4: return .title3
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .h2, .h3:
                return EdgeInsets(top: 48, leading: 0, bottom: 0, trailing: 0)
            case .h4:
                return EdgeInsets(top: 32, leading: 0, bottom: 0, trailing: 0)
            }
        }
    }
    
    var body: some View {
        if let text = text {
            Text(text)
                .font(level.font)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(level.padding)
        }
    }
}



struct ParagraphTextView: View {
    let attributedText: AttributedString?
    
    var body: some View {
        if let text = attributedText {
            Text(text)
                .lineSpacing(8)
                .padding(.vertical, 8)
        }
    }
}

struct ListItemView: View {
    let attributedText: AttributedString?
    let isOrdered: Bool
    @State private var order: Int = 1
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if isOrdered {
                Text("\(order).")
                    .foregroundColor(.secondary)
            } else {
                Text("•")
                    .foregroundColor(.secondary)
            }
            
            if let text = attributedText {
                Text(text)
                    .lineSpacing(8)
            }
        }
        .padding(.vertical, 4)
        .padding(.leading, 16)
    }
}

struct CodeBlockView: View {
    let paragraph: Paragraph
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let lang = paragraph.codeBlockMetadata?.lang {
                Text(lang)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
            
            ScrollView(.horizontal, showsIndicators: true) {
                if let text = paragraph.text {
                    Text(text)
                        .font(.system(.body, design: .monospaced))
                        .padding(16)
                }
            }
        }
        .background(Color(.systemGray))
        .cornerRadius(8)
        .padding(.vertical, 8)
    }
}

struct BlockquoteView: View {
    let attributedText: AttributedString?
    
    var body: some View {
        if let text = attributedText {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 3)
                
                Text(text)
                    .italic()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .background(Color(.systemGray).opacity(0.3))
            .padding(.vertical, 8)
        }
    }
}

struct PullQuoteView: View {
    let attributedText: AttributedString?
    
    var body: some View {
        if let text = attributedText {
            Text(text)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
        }
    }
}

struct MixtapeEmbedView: View {
    let paragraph: Paragraph
    
    var body: some View {
        if let metadata = paragraph.mixtapeMetadata,
           let url = URL(string: metadata.href) {
            Link(destination: url) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        if let title = extractEmbedTitle() {
                            Text(title)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        if let description = extractEmbedDescription() {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let site = extractEmbedSite(from: url) {
                            Text(site)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let thumbnailId = metadata.thumbnailImageId {
                        AsyncImage(url: URL(string: "https://miro.medium.com/v2/resize:fit:320/\(thumbnailId)")) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipped()
                            case .failure:
                                Image(systemName: "photo")
                                    .foregroundColor(.secondary)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .cornerRadius(8)
                    }
                }
                .padding(16)
                .background(Color(.systemGray))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.vertical, 8)
        }
    }
    
    private func extractEmbedTitle() -> String? {
        // Implementation needed based on markup parsing
        return paragraph.text?.components(separatedBy: "\n").first
    }
    
    private func extractEmbedDescription() -> String? {
        // Implementation needed based on markup parsing
        return paragraph.text?.components(separatedBy: "\n").dropFirst().first
    }
    
    private func extractEmbedSite(from url: URL) -> String? {
        return url.host?
            .replacingOccurrences(of: "www.", with: "")
            .components(separatedBy: ".")
            .first?
            .capitalized
    }
}




struct ContentView2: View {
    
    
    var body: some View {
        VStack{
            PostContentView()
        }
        
    }
}

struct PostContentView: View {
    @StateObject var viewModel : PostContentViewModel = PostContentViewModel()
    
  
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.paragraphs) { paragraph in
                    ParagraphView(paragraph: paragraph)
                }
            }
            .padding()
        }
        .onAppear{
            Task{
               await viewModel.getPostContent()
            }
        }
    }
}

//
//
//init(postData: [String: Any]) {
//       let content = Content(bodyModel: Content.BodyModel(paragraphs: []))  // Parse your actual content
//       let title = ""  // Your actual title
//       let subtitle = ""  // Your actual subtitle
//       let previewImageId = ""  // Your actual preview image id
//       let highlights: [Highlight] = []  // Your actual highlights
//       let tags: [PostContentViewModel.Tag] = []  // Your actual tags
//       
//       _viewModel = StateObject(wrappedValue: PostContentViewModel(
//           content: content,
//           title: title,
//           subtitle: subtitle,
//           previewImageId: previewImageId,
//           highlights: highlights,
//           tags: tags
//       ))
//   }
//   

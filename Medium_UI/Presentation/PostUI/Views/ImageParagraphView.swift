//
//  ImageParagraphView.swift
//  Medium_UI
//
//  Created by shahanul on 11/19/24.
//

import SwiftUI

struct ImageParagraphView: View {
    let paragraph: Paragraph
    let layout: ImageLayout
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    enum ImageLayout {
        case single, row
        
        func maxWidth(containerWidth: CGFloat?) -> CGFloat {
            switch self {
            case .single:
                return .infinity
            case .row:
                #if os(macOS)
                let width = containerWidth ?? (NSScreen.main?.frame.width ?? 800)
                #else
                let width = containerWidth ?? (UIScreen.main.bounds.width)
                #endif
                return width / 2
            }
        }
    }
    
    init(paragraph: Paragraph) {
        self.paragraph = paragraph
        self.layout = paragraph.layout == .outsetRow || paragraph.layout == .outsetRowContinue ? .row : .single
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                if let url = imageURL
                {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: layout.maxWidth(containerWidth: geometry.size.width))
                        case .success(let image):
                            image
//                                .resizable()
                              //  .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: layout.maxWidth(containerWidth: geometry.size.width))
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: layout.maxWidth(containerWidth: geometry.size.width))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    #if os(iOS)
                    .contextMenu {
                        ShareLink(item: url) {
                            Label("Share Image", systemImage: "square.and.arrow.up")
                        }
                    }
                    #endif
                }
                
                if let caption = paragraph.text {
                    Text(caption)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        #if os(iOS)
                        .padding(.horizontal, horizontalSizeClass == .regular ? 16 : 8)
                        #endif
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(Color.teal)
        }
    }
    
    private var imageURL: URL? {
        guard let id = paragraph.metadata?.id else { return nil }
        #if os(iOS)
        let scale = UIScreen.main.scale
        #else
        let scale = NSScreen.main?.backingScaleFactor ?? 2
        #endif
//        return URL(string: "https://miro.medium.com/v2/resize:fit:700/format:webp/\(id)?dpr=\(scale)")
        return URL(string: "https://miro.medium.com/v2/resize:fit:700/\(id)")
    }
}

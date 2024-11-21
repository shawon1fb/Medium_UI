//
//  Paragraph.swift
//  Medium_UI
//
//  Created by shahanul on 11/21/24.
//

import Foundation

struct Paragraph: Codable, Identifiable {
    let id = UUID()
    let type: ParagraphType
    let text: String?
    let name: String?
    let markups: [Markup]
    let layout: LayoutType?
    let metadata: ImageMetadata?
    let codeBlockMetadata: CodeBlockMetadata?
    let mixtapeMetadata: MixtapeMetadata?
    let iframe: IframeData?
    
    enum ParagraphType: String, Codable {
        case h2 = "H2"
        case h3 = "H3"
        case h4 = "H4"
        case image = "IMG"
        case paragraph = "P"
        case unorderedList = "ULI"
        case orderedList = "OLI"
        case preformatted = "PRE"
        case blockquote = "BQ"
        case pullQuote = "PQ"
        case mixtapeEmbed = "MIXTAPE_EMBED"
        case iframe = "IFRAME"
    }
    
    enum LayoutType: String, Codable {
        case outsetRow = "OUTSET_ROW"
        case outsetRowContinue = "OUTSET_ROW_CONTINUE"
        case fullWidth = "FULL_WIDTH"
        case insertCenter = "INSET_CENTER"
    }
}

struct Markup: Codable {
    let start: Int
    let end: Int
    let type: MarkupType
    let href: String?
    let title: String?
    
    enum MarkupType: String, Codable {
        case strong = "STRONG"
        case em = "EM"
        case link = "A"
        case code = "CODE"
        case strike = "STRIKE"
    }
}

struct ImageMetadata: Codable {
    let id: String
    let originalWidth: Int?
    let originalHeight: Int?
    let alt: String?
}

struct CodeBlockMetadata: Codable {
    let lang: String?
    let mode: String?
}

struct MixtapeMetadata: Codable {
    let href: String
    let thumbnailImageId: String?
    let mediaResourceId: String?
}

struct IframeData: Codable {
    let mediaResource: MediaResource
    
    struct MediaResource: Codable {
        let id: String
        let iframeSrc: String?
    }
}

struct HighlightModel: Codable {
    let startOffset: Int
    let endOffset: Int
    let paragraphs: [HighlightParagraph]
    
    struct HighlightParagraph: Codable {
        let name: String
        let text: String
    }
}


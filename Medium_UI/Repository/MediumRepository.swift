//
//  MediumRepository.swift
//  Medium_UI
//
//  Created by shahanul on 11/18/24.
//
import MediumCore
import EasyXConnect
import Foundation

let cookies = """
nonce=T7aIMuwO; sid=1:52faA8DC6EImpEYnGwTR09v+oSs7ThMU15MTtQghOoiUHrCGSgCrs+v0ZzdA/p31; uid=50f56619a720; _ga_L0TFYZVE5F=GS1.2.1729277385.1.0.1729277385.0.0.0; _ga=GA1.1.1796673625.1727885938; _cfuvid=.x369j0tDe5zvXLWHsUynaDU9rBe4qUYb3nRxvA8rzc-1731414895085-0.0.1.1-604800000; xsrf=61254c61b5b6; cf_clearance=Kq1IE332U77rgS93ER8ODhPJnlUcbAs.TfO2KOZ6eBM-1731511413-1.2.1.1-wntaNS_BcQCRKjJ_nk8dMqzDTQwUtbR003VPPAupvopkaeZ5VnOJ5p7n7x9.R4CIWUPHglCIe_3sQrM_sWWmioyzIxHBEzWZUTGq8L4vYYfaVxbimC2YLuZt96_AvHyLWRVnONV9qAXYVge7ItkEWC9Q.yWGu9HTMgY8AWKaXT5Wdkunpl2qhM.PKKTZLnOOwfmvymHI7HWexZcxyXgWPFClHjqs1APF5PD1bcxrztaxZ2gWqFuVYNtK5r4VZFtN9iyQXsbs8Wowbwp1L5DCFMuQhAmEv42lcfvjSWFfc0SB_xgCEYjqXwA1U2igAa1yrXa2IWmmWcIi54qCW4jO.kzekMUfAyTIhLAfhQNFKsOiw53bN.xiY4u14vYAnBGNNjOXevPoahcvD.IakQ0SMQ; _ga_7JY7T788PK=GS1.1.1731513825.52.1.1731515343.0.0.0; _dd_s=rum=0&expire=1731516243460
"""

actor MediumRepository{
    
    func getPost()async throws -> [Paragraph]{
        let postId = try await MediumParserUtility().resolveMediumURL("https://medium.com/@kalidoss.shanmugam/ios-animation-excellence-best-practices-and-solutions-for-common-issues-61f937748c39")
        
        print("postId -> \(postId)")
        
        let data = try await MediumApi(authCookies: "").queryPostById(postId: postId)
//        print(String(data: data, encoding: .utf8))
        do{
        
            let response: AppResponse<MediumPostResponse> = try DataToObjectConverter.dataToObject(data: data, statusCode: 200)
            print(response)
            return response.payload?.data.post.content.bodyModel.paragraphs ?? []
        }catch{
            print("error -> \(error)")
        }
        
        return []
   
    }
    
    func getPost2()async throws -> Post{
        let url = "https://medium.com/@itsuki.enjoy/swift-ios-real-time-human-traffic-tracker-01f1f6ade3f3"
        let postId = try await MediumParserUtility().resolveMediumURL( url
                                                                       //"https://medium.com/@kalidoss.shanmugam/ios-animation-excellence-best-practices-and-solutions-for-common-issues-61f937748c39"
        )
        
        print("postId -> \(postId)")
        
        let data = try await MediumApi(authCookies: "").queryPostById(postId: postId)
//        print(String(data: data, encoding: .utf8))
        do{
        
            let response: AppResponse<MediumPostResponse> = try DataToObjectConverter.dataToObject(data: data, statusCode: 200)
            print(response)
            if let post = response.payload?.data.post{
                return post
            }
            throw NotFoundException()
        }
   
    }
}
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

struct Highlight: Codable {
    let startOffset: Int
    let endOffset: Int
    let paragraphs: [HighlightParagraph]
    
    struct HighlightParagraph: Codable {
        let name: String
        let text: String
    }
}


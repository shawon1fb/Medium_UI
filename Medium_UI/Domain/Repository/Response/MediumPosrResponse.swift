//
//  MediumPosrResponse.swift
//  Medium_UI
//
//  Created by shahanul on 11/18/24.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let mediumPostResponse = try? JSONDecoder().decode(MediumPostResponse.self, from: jsonData)

import AppKit
import Foundation

// MARK: - MediumPostResponse
struct MediumPostResponse: Codable {
  let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
  let post: Post
}

// MARK: - Post
struct Post: Codable {
  let typename, id: String
  let readingTime: Double
  let creator: Creator
  let isLocked: Bool
  let firstPublishedAt: Int
  let latestPublishedVersion, title, visibility: String
  let postResponses: PostResponses
  let clapCount: Int
  let viewerEdge: PostViewerEdge
  let detectedLanguage: String
  let mediumURL: String
  let updatedAt: Int
  let allowResponses, isProxyPost, isSeries: Bool
  let previewImage: PreviewImage
  let inResponseToPostResult, inResponseToMediaResource, inResponseToEntityType: JSONNull?
  let canonicalURL: String
  let previewContent: PreviewContent
  let pinnedByCreatorAt: Int
  let linkMetadataList: [LinkMetadataList]
  let highlights: [HighlightModel]
  let responsesLocked: Bool
  let tags: [Tag]
  let content: Content

  enum CodingKeys: String, CodingKey {
    case typename = "__typename"
    case id, readingTime, creator, isLocked, firstPublishedAt, latestPublishedVersion, title,
      visibility, postResponses, clapCount, viewerEdge, detectedLanguage
    case mediumURL = "mediumUrl"
    case updatedAt, allowResponses, isProxyPost, isSeries, previewImage, inResponseToPostResult,
      inResponseToMediaResource, inResponseToEntityType
    case canonicalURL = "canonicalUrl"
    case previewContent, pinnedByCreatorAt, linkMetadataList, highlights, responsesLocked, tags,
      content
  }
}

// MARK: - Content
struct Content: Codable {
  let bodyModel: BodyModel
  let validatedShareKey: String
}

// MARK: - BodyModel
struct BodyModel: Codable {
  let typename: String
  let sections: [Section]
  let paragraphs: [Paragraph]

  enum CodingKeys: String, CodingKey {
    case typename = "__typename"
    case sections, paragraphs
  }
    
    func getAllText() -> String {
        return paragraphs.compactMap { $0.text }.joined(separator: "\n")
    }

}

// MARK: - Paragraph
//struct Paragraph: Codable {
//    let typename: ParagraphTypename
//    let id, name: String
//    let href: String?
//    let text: String
//    let iframe: JSONNull?
//    let layout: String?
//    let markups: [Markup]
//    let metadata: Metadata?
//    let mixtapeMetadata: JSONNull?
//    let type: ParagraphType
//    let hasDropCap: Bool?
//    let dropCapImage: JSONNull?
//    let codeBlockMetadata: CodeBlockMetadata?
//
//    enum CodingKeys: String, CodingKey {
//        case typename = "__typename"
//        case id, name, href, text, iframe, layout, markups, metadata, mixtapeMetadata, type, hasDropCap, dropCapImage, codeBlockMetadata
//    }
//}
//
//// MARK: - CodeBlockMetadata
//struct CodeBlockMetadata: Codable {
//    let lang: Lang
//    let mode: Mode
//}
//
//enum Lang: String, Codable {
//    case php = "php"
//    case swift = "swift"
//}
//
//enum Mode: String, Codable {
//    case auto = "AUTO"
//    case explicit = "EXPLICIT"
//}
//
//// MARK: - Markup
//struct Markup: Codable {
//    let typename: MarkupTypename
//    let name: JSONNull?
//    let type: MarkupType
//    let start, end: Int
//    let href, title, rel, anchorType: JSONNull?
//    let userID, creatorIDS: JSONNull?
//
//    enum CodingKeys: String, CodingKey {
//        case typename = "__typename"
//        case name, type, start, end, href, title, rel, anchorType
//        case userID = "userId"
//        case creatorIDS = "creatorIds"
//    }
//}

enum MarkupType: String, Codable {
  case code = "CODE"
  case em = "EM"
  case strong = "STRONG"
}

enum MarkupTypename: String, Codable {
  case markup = "Markup"
}

// MARK: - Metadata
struct Metadata: Codable {
  let typename, id: String
  let originalWidth, originalHeight: Int
  let focusPercentX, focusPercentY, alt: JSONNull?

  enum CodingKeys: String, CodingKey {
    case typename = "__typename"
    case id, originalWidth, originalHeight, focusPercentX, focusPercentY, alt
  }
}

enum ParagraphType: String, Codable {
  case bq = "BQ"
  case h3 = "H3"
  case h4 = "H4"
  case img = "IMG"
  case p = "P"
  case pre = "PRE"
}

enum ParagraphTypename: String, Codable {
  case paragraph = "Paragraph"
}

// MARK: - Section
struct Section: Codable {
  let typename, name: String
  let startIndex: Int
  let textLayout, imageLayout, videoLayout, backgroundImage: JSONNull?
  let backgroundVideo: JSONNull?

  enum CodingKeys: String, CodingKey {
    case typename = "__typename"
    case name, startIndex, textLayout, imageLayout, videoLayout, backgroundImage, backgroundVideo
  }
}

// MARK: - Creator
struct Creator: Codable {
  let typename, id, imageID, username: String
  let name, bio: String

  let socialStats: SocialStats?
  let newsletterV3: NewsletterV3?

  let mediumMemberAt: Int?
  let twitterScreenName: String?

  enum CodingKeys: String, CodingKey {
    case typename = "__typename"
    case id
    case imageID = "imageId"
    case username, name, bio, socialStats, newsletterV3, mediumMemberAt, twitterScreenName
  }
}

// MARK: - NewsletterV3
struct NewsletterV3: Codable {
  let typename, id: String
  let viewerEdge: NewsletterV3ViewerEdge

  enum CodingKeys: String, CodingKey {
    case typename = "__typename"
    case id, viewerEdge
  }
}

// MARK: - NewsletterV3ViewerEdge
struct NewsletterV3ViewerEdge: Codable {
  let id: String
  let isSubscribed: Bool
}

// MARK: - SocialStats
struct SocialStats: Codable {
  let followingCount, followerCount: Int
}

// MARK: - CreatorViewerEdge
struct CreatorViewerEdge: Codable {
  let isUser, isFollowing, isBlocking, isMuting: Bool
}

// MARK: - LinkMetadataList
struct LinkMetadataList: Codable {
  let url: String
  let alts: [JSONAny]
}

// MARK: - PostResponses
struct PostResponses: Codable {
  let count: Int
}

// MARK: - PreviewContent
struct PreviewContent: Codable {
  let subtitle: String
}

// MARK: - PreviewImage
struct PreviewImage: Codable {
  let id: String

  var imageURL: URL {
    #if os(iOS)
      let scale = UIScreen.main.scale
    #else
      let scale = NSScreen.main?.backingScaleFactor ?? 2
    #endif
    return URL(string: "https://miro.medium.com/v2/resize:fit:700/format:webp/\(id)?dpr=\(scale)")!
  }
}

// MARK: - Tag
struct Tag: Codable {
  let typename, id, normalizedTagSlug, displayTitle: String
  let followerCount, postCount: Int

  enum CodingKeys: String, CodingKey {
    case typename = "__typename"
    case id, normalizedTagSlug, displayTitle, followerCount, postCount
  }
}

// MARK: - PostViewerEdge
struct PostViewerEdge: Codable {
  let clapCount: Int
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

  public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
    return true
  }

    func hash(into hasher: inout Hasher) {
        
    }

  public init() {}

  public required init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if !container.decodeNil() {
      throw DecodingError.typeMismatch(
        JSONNull.self,
        DecodingError.Context(
          codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encodeNil()
  }
}

class JSONCodingKey: CodingKey {
  let key: String

  required init?(intValue: Int) {
    return nil
  }

  required init?(stringValue: String) {
    key = stringValue
  }

  var intValue: Int? {
    return nil
  }

  var stringValue: String {
    return key
  }
}

class JSONAny: Codable {

  let value: Any

  static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
    let context = DecodingError.Context(
      codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
    return DecodingError.typeMismatch(JSONAny.self, context)
  }

  static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
    let context = EncodingError.Context(
      codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
    return EncodingError.invalidValue(value, context)
  }

  static func decode(from container: SingleValueDecodingContainer) throws -> Any {
    if let value = try? container.decode(Bool.self) {
      return value
    }
    if let value = try? container.decode(Int64.self) {
      return value
    }
    if let value = try? container.decode(Double.self) {
      return value
    }
    if let value = try? container.decode(String.self) {
      return value
    }
    if container.decodeNil() {
      return JSONNull()
    }
    throw decodingError(forCodingPath: container.codingPath)
  }

  static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
    if let value = try? container.decode(Bool.self) {
      return value
    }
    if let value = try? container.decode(Int64.self) {
      return value
    }
    if let value = try? container.decode(Double.self) {
      return value
    }
    if let value = try? container.decode(String.self) {
      return value
    }
    if let value = try? container.decodeNil() {
      if value {
        return JSONNull()
      }
    }
    if var container = try? container.nestedUnkeyedContainer() {
      return try decodeArray(from: &container)
    }
    if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
      return try decodeDictionary(from: &container)
    }
    throw decodingError(forCodingPath: container.codingPath)
  }

  static func decode(
    from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey
  ) throws -> Any {
    if let value = try? container.decode(Bool.self, forKey: key) {
      return value
    }
    if let value = try? container.decode(Int64.self, forKey: key) {
      return value
    }
    if let value = try? container.decode(Double.self, forKey: key) {
      return value
    }
    if let value = try? container.decode(String.self, forKey: key) {
      return value
    }
    if let value = try? container.decodeNil(forKey: key) {
      if value {
        return JSONNull()
      }
    }
    if var container = try? container.nestedUnkeyedContainer(forKey: key) {
      return try decodeArray(from: &container)
    }
    if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
      return try decodeDictionary(from: &container)
    }
    throw decodingError(forCodingPath: container.codingPath)
  }

  static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
    var arr: [Any] = []
    while !container.isAtEnd {
      let value = try decode(from: &container)
      arr.append(value)
    }
    return arr
  }

  static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws
    -> [String: Any]
  {
    var dict = [String: Any]()
    for key in container.allKeys {
      let value = try decode(from: &container, forKey: key)
      dict[key.stringValue] = value
    }
    return dict
  }

  static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
    for value in array {
      if let value = value as? Bool {
        try container.encode(value)
      } else if let value = value as? Int64 {
        try container.encode(value)
      } else if let value = value as? Double {
        try container.encode(value)
      } else if let value = value as? String {
        try container.encode(value)
      } else if value is JSONNull {
        try container.encodeNil()
      } else if let value = value as? [Any] {
        var container = container.nestedUnkeyedContainer()
        try encode(to: &container, array: value)
      } else if let value = value as? [String: Any] {
        var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
        try encode(to: &container, dictionary: value)
      } else {
        throw encodingError(forValue: value, codingPath: container.codingPath)
      }
    }
  }

  static func encode(
    to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]
  ) throws {
    for (key, value) in dictionary {
      let key = JSONCodingKey(stringValue: key)!
      if let value = value as? Bool {
        try container.encode(value, forKey: key)
      } else if let value = value as? Int64 {
        try container.encode(value, forKey: key)
      } else if let value = value as? Double {
        try container.encode(value, forKey: key)
      } else if let value = value as? String {
        try container.encode(value, forKey: key)
      } else if value is JSONNull {
        try container.encodeNil(forKey: key)
      } else if let value = value as? [Any] {
        var container = container.nestedUnkeyedContainer(forKey: key)
        try encode(to: &container, array: value)
      } else if let value = value as? [String: Any] {
        var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
        try encode(to: &container, dictionary: value)
      } else {
        throw encodingError(forValue: value, codingPath: container.codingPath)
      }
    }
  }

  static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
    if let value = value as? Bool {
      try container.encode(value)
    } else if let value = value as? Int64 {
      try container.encode(value)
    } else if let value = value as? Double {
      try container.encode(value)
    } else if let value = value as? String {
      try container.encode(value)
    } else if value is JSONNull {
      try container.encodeNil()
    } else {
      throw encodingError(forValue: value, codingPath: container.codingPath)
    }
  }

  public required init(from decoder: Decoder) throws {
    if var arrayContainer = try? decoder.unkeyedContainer() {
      self.value = try JSONAny.decodeArray(from: &arrayContainer)
    } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
      self.value = try JSONAny.decodeDictionary(from: &container)
    } else {
      let container = try decoder.singleValueContainer()
      self.value = try JSONAny.decode(from: container)
    }
  }

  public func encode(to encoder: Encoder) throws {
    if let arr = self.value as? [Any] {
      var container = encoder.unkeyedContainer()
      try JSONAny.encode(to: &container, array: arr)
    } else if let dict = self.value as? [String: Any] {
      var container = encoder.container(keyedBy: JSONCodingKey.self)
      try JSONAny.encode(to: &container, dictionary: dict)
    } else {
      var container = encoder.singleValueContainer()
      try JSONAny.encode(to: &container, value: self.value)
    }
  }
}

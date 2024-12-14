//
//  MediumPostListResponse.swift
//  Medium_UI
//
//  Created by shahanul on 12/14/24.
//

import Foundation

// MARK: - MediumPostResponseElement
struct MediumPostResponseElement: Codable {
    let data: PostListDataClass
}

// MARK: - DataClass
struct PostListDataClass: Codable {
    let webRecommendedFeed: WebRecommendedFeed
}

// MARK: - WebRecommendedFeed
struct WebRecommendedFeed: Codable {
    let items: [PostItemResponse]
}

// MARK: - Item
struct PostItemResponse: Codable {
    let feedID: String
    let moduleSourceEncoding, reason: Int
    let post: PostSingleItem

    enum CodingKeys: String, CodingKey {
        case feedID = "feedId"
        case moduleSourceEncoding, reason, post
    }
}

// MARK: - Post
struct PostSingleItem: Codable {
    let id, title: String
    let previewImage: PreviewImage
    let extendedPreviewContent: ExtendedPreviewContent
    let typename: String
    let creator: Creator
    let isPublished: Bool
    let mediumURL: String
    let isLimitedState, allowResponses: Bool
    let postResponses: PostResponses
    let visibility: String
    let clapCount: Int
    let isLocked: Bool
    let firstPublishedAt, latestPublishedAt, pinnedAt: Int
    let readingTime: Double
    let isSeries: Bool
    let uniqueSlug: String

    enum CodingKeys: String, CodingKey {
        case id, title, previewImage, extendedPreviewContent
        case typename = "__typename"
        case creator, isPublished
        case mediumURL = "mediumUrl"
        case isLimitedState, allowResponses, postResponses, visibility, clapCount, isLocked, firstPublishedAt, latestPublishedAt, pinnedAt, readingTime, isSeries, uniqueSlug
    }
}

// MARK: - CustomDomainState
struct CustomDomainState: Codable {
    let live: Live
    let typename: String

    enum CodingKeys: String, CodingKey {
        case live
        case typename = "__typename"
    }
}

// MARK: - Live
struct Live: Codable {
    let domain, typename: String

    enum CodingKeys: String, CodingKey {
        case domain
        case typename = "__typename"
    }
}

// MARK: - Membership
struct Membership: Codable {
    let tier, typename, id: String

    enum CodingKeys: String, CodingKey {
        case tier
        case typename = "__typename"
        case id
    }
}

// MARK: - Verifications
struct Verifications: Codable {
    let isBookAuthor: Bool
    let typename: String

    enum CodingKeys: String, CodingKey {
        case isBookAuthor
        case typename = "__typename"
    }
}

// MARK: - ViewerEdge
struct ViewerEdge: Codable {
    let id: String
    let isMuting: Bool
    let typename: String

    enum CodingKeys: String, CodingKey {
        case id, isMuting
        case typename = "__typename"
    }
}

// MARK: - ExtendedPreviewContent
struct ExtendedPreviewContent: Codable {
    let subtitle, typename: String
    let isFullContent: Bool

    enum CodingKeys: String, CodingKey {
        case subtitle
        case typename = "__typename"
        case isFullContent
    }
}


typealias MediumPostListResponse = [ MediumPostResponseElement ]

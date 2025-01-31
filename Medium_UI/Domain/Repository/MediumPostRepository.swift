import EasyXConnect
//
//  MediumPostRepository.swift
//  Medium_UI
//
//  Created by shahanul on 12/16/24.
//
import Foundation
import MediumCore

final class MediumPostRepositoryBindings{
    
    func getDependencies() -> MediumPostRepository {
        let baseURL = URL(string: "https://medium.com/_/graphql")!
        return MediumPostRepository(client: ExHttpConnect(baseURL: baseURL), authCookie: cookieKey)
    }
}

actor MediumPostRepository: IMediumRepository {

  let client: ExHttpConnect
  let authCookie: String

  init(client: ExHttpConnect, authCookie: String = cookieKey) {
    self.client = client
    self.authCookie = authCookie
  }

  func getMediumPosts(dto: MediumPostListDTO) async throws -> [PostSingleItem] {
    do {

      var postsList: [PostSingleItem] = []
        let headers: [String: String] = [
        "Pragma": "no-cache",
        "graphql-operation": "WebInlineRecommendedFeedQuery",
        "medium-frontend-path": "/",
        "medium-frontend-route": "homepage",
        "apollographql-client-version": "main-20241212-205827-84030d187b",
        "apollographql-client-name": "lite",
        "medium-frontend-app": "lite/main-20241212-205827-84030d187b",
        "Cookie": authCookie,
        "content-type": "application/json",
      ]
      let dtos: MediumPostListDTOS = [dto]
//      let baseURL = URL(string: "https://medium.com/_/graphql")!
//      let client = ExHttpConnect(baseURL: baseURL)

      let response: AppResponse<MediumPostListResponse> = try await client.post(
        "", body: dtos.toData(), headers: headers)

      if let posts = response.payload?.first {
        postsList = posts.data.webRecommendedFeed.items.map({ $0.post })
      }
      return postsList
    }
  }

  func getPostByID(postID: String) async throws -> Post {
      
      print("requesting postID  \(postID)")
    let data = try await MediumApi(authCookies: "").queryPostById(postId: postID)
//    let data = try await MediumApi(authCookies: "").queryPostById(postId: "f29ea5c47516")

    do {

      let response: AppResponse<MediumPostResponse> = try DataToObjectConverter.dataToObject(
        data: data, statusCode: 200)

      if let post = response.payload?.data.post {

        return post
      }
      throw NotFoundException()
    }
  }

  func getPostByURL(postURL: String) async throws -> Post {

    let postId = try await MediumParserUtility()
      .resolveMediumURL(
        postURL
      )
    return try await getPostByID(postID: postId)

  }

}

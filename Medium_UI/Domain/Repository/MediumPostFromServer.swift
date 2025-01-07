//
//  MediumPostFromServer.swift
//  Medium_UI
//
//  Created by Shahanul Haque on 1/7/25.
//

import EasyXConnect
//
//  MediumPostRepository.swift
//  Medium_UI
//
//  Created by shahanul on 12/16/24.
//
import Foundation
import MediumCore



final class MediumPostFromServerRepositoryBindings{
    
    func getDependencies() -> MediumPostFromServerRepository {
        let baseURL = URL(string: "https://medium.com/_/graphql")!
        return MediumPostFromServerRepository(client: ExHttpConnect(baseURL: baseURL), authCookie: cookieKey)
    }
}

actor MediumPostFromServerRepository: IMediumRepository {

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
  //  let data = try await MediumApi(authCookies: "").queryPostById(postId: postID)
//    let data = try await MediumApi(authCookies: "").queryPostById(postId: "f29ea5c47516")
      
      
      let headers: [String: String] = [
     
//      "content-type": "application/json",
      "Accept": "application/json",
      "Content-Type": "application/json"
    ]

    do {
        let baseURL = URL(string: "http://127.0.0.1:3000/\(postID)")!
        let client = ExHttpConnect(baseURL: baseURL)
        let response: AppResponse<MediumPostResponse> = try await client.get("", headers: headers)

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

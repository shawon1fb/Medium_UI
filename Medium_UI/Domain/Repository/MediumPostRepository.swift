import EasyXConnect
//
//  MediumPostRepository.swift
//  Medium_UI
//
//  Created by shahanul on 12/16/24.
//
import Foundation
import MediumCore

let cookieKey =
  "nonce=T7aIMuwO; sid=1:52faA8DC6EImpEYnGwTR09v+oSs7ThMU15MTtQghOoiUHrCGSgCrs+v0ZzdA/p31; uid=50f56619a720; _ga_L0TFYZVE5F=GS1.2.1732637225.3.1.1732637322.0.0.0; _ga=GA1.1.1796673625.1727885938; _cfuvid=Ii4v0_3IQRm.Vevl59JaZ4rswaqfE6JmDdckRWIiN.M-1733844917447-0.0.1.1-604800000; xsrf=62abc7b8aba3; cf_clearance=LGC5M7WVGYOHD4SMRcs0EkoWFmmKK7CUSv8XWDT7W04-1734184684-1.2.1.1-GdRQH5voXnHnpizFVL.MzUFmgxxY_awMNAajrBJqdlzaL3lnuFlj03gzVQWWyGAAv08t_STyEkuG50sr0uJCPFgGDGUXUtrvXScIsi_jwsCIkdBtvd.ieyzwY.GhghISqCTWnmFJkI1hRNPTPCSKKD9eNltr0XBHpASGPbrUrZHaSI55tGEh1rzFV9_ogCBBsmlnz8hPtlJyMk7NktzxFASEbmfZKu37TiVwRQQQ7lfZKwn4wLwzh_pSXEy8mqwK_fGsM4gRjqq.NgfRT.BNQKes13y6fuPCi8JPTyWywPwmOHiviUZL5NwcpS9g_gXBU1gLszOH8UQ6HZCn659qLwtzopB85x8c8AZbvss8nmIBxplnKNfwIIHlaiwWGzCxoCU2gvSCb4sEuTFGIR67Ug; _ga_7JY7T788PK=GS1.1.1734183680.109.1.1734185156.0.0.0; _dd_s=rum"

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
      let baseURL = URL(string: "https://medium.com/_/graphql")!
      let client = ExHttpConnect(baseURL: baseURL)

      let response: AppResponse<MediumPostListResponse> = try await client.post(
        "", body: dtos.toData(), headers: headers)

      if let posts = response.payload?.first {
        postsList = posts.data.webRecommendedFeed.items.map({ $0.post })
      }
      return postsList
    }
  }

  func getPostByID(postID: String) async throws -> Post {
    let data = try await MediumApi(authCookies: "").queryPostById(postId: postID)

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

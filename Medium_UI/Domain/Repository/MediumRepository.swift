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
//        let url = "https://medium.com/@itsuki.enjoy/swift-ios-real-time-human-traffic-tracker-01f1f6ade3f3"
//        let url = "https://medium.com/@amin-softtech/top-10-swiftui-errors-developers-face-and-how-to-fix-them-23f14a181d51"
        
//        let url = "https://medium.com/glovo-engineering/linting-and-formatting-swift-code-in-our-apps-a49dc0a52332"
        
//        let url = "https://medium.com/@pp.palinda/parallel-processing-in-nestjs-6ecdbc533e1f"
//        let url = "https://itnext.io/the-zsh-shell-tricks-i-wish-id-known-earlier-ae99e91c53c2"
        let url = "https://medium.com/mongodb/what-are-ai-agents-from-virtual-assistants-to-intelligent-decision-makers-817b8b205f33"
        let postId = try await MediumParserUtility().resolveMediumURL(
            url
//                                                                       "https://medium.com/@kalidoss.shanmugam/ios-animation-excellence-best-practices-and-solutions-for-common-issues-61f937748c39"
        )
        
        print("postId -> \(postId)")
        
        let data = try await MediumApi(authCookies: "").queryPostById(postId: postId)
//        print(String(data: data, encoding: .utf8))
        do{
        
            let response: AppResponse<MediumPostResponse> = try DataToObjectConverter.dataToObject(data: data, statusCode: 200)
//            print(response)
            if let post = response.payload?.data.post{
                print(post.toPrettyJson())
                return post
            }
            throw NotFoundException()
        }
   
    }
    
    
    func getMediumPosts(dto : MediumPostListDTO) async throws-> [PostSingleItem] {
        
        do{
            
            var postsList:[PostSingleItem] = []
            var headers: [String: String] = [
                "Pragma": "no-cache",
                "graphql-operation": "WebInlineRecommendedFeedQuery",
                "medium-frontend-path": "/",
                "medium-frontend-route": "homepage",
                "apollographql-client-version": "main-20241212-205827-84030d187b",
                "apollographql-client-name": "lite",
                "medium-frontend-app": "lite/main-20241212-205827-84030d187b",
                "Cookie": "nonce=T7aIMuwO; sid=1:52faA8DC6EImpEYnGwTR09v+oSs7ThMU15MTtQghOoiUHrCGSgCrs+v0ZzdA/p31; uid=50f56619a720; _ga_L0TFYZVE5F=GS1.2.1732637225.3.1.1732637322.0.0.0; _ga=GA1.1.1796673625.1727885938; _cfuvid=Ii4v0_3IQRm.Vevl59JaZ4rswaqfE6JmDdckRWIiN.M-1733844917447-0.0.1.1-604800000; xsrf=62abc7b8aba3; cf_clearance=LGC5M7WVGYOHD4SMRcs0EkoWFmmKK7CUSv8XWDT7W04-1734184684-1.2.1.1-GdRQH5voXnHnpizFVL.MzUFmgxxY_awMNAajrBJqdlzaL3lnuFlj03gzVQWWyGAAv08t_STyEkuG50sr0uJCPFgGDGUXUtrvXScIsi_jwsCIkdBtvd.ieyzwY.GhghISqCTWnmFJkI1hRNPTPCSKKD9eNltr0XBHpASGPbrUrZHaSI55tGEh1rzFV9_ogCBBsmlnz8hPtlJyMk7NktzxFASEbmfZKu37TiVwRQQQ7lfZKwn4wLwzh_pSXEy8mqwK_fGsM4gRjqq.NgfRT.BNQKes13y6fuPCi8JPTyWywPwmOHiviUZL5NwcpS9g_gXBU1gLszOH8UQ6HZCn659qLwtzopB85x8c8AZbvss8nmIBxplnKNfwIIHlaiwWGzCxoCU2gvSCb4sEuTFGIR67Ug; _ga_7JY7T788PK=GS1.1.1734183680.109.1.1734185156.0.0.0; _dd_s=rum",
                "content-type": "application/json"
            ]
            let dtos: MediumPostListDTOS = [ dto ]
            let baseURL = URL(string: "https://medium.com/_/graphql")!
            let client = ExHttpConnect(baseURL: baseURL)
            
            let response : AppResponse<MediumPostListResponse> =  try await client.post("", body: dtos.toData(), headers: headers)
            
            if let posts = response.payload?.first {
                postsList = posts.data.webRecommendedFeed.items.map({$0.post})
            }
            return postsList
        }
    }
}

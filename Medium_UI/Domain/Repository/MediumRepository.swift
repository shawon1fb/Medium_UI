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
        let url = "https://medium.com/@amin-softtech/top-10-swiftui-errors-developers-face-and-how-to-fix-them-23f14a181d51"
//        let url = "https://medium.com/glovo-engineering/linting-and-formatting-swift-code-in-our-apps-a49dc0a52332"
        let postId = try await MediumParserUtility().resolveMediumURL(
            url
//                                                                       "https://medium.com/@kalidoss.shanmugam/ios-animation-excellence-best-practices-and-solutions-for-common-issues-61f937748c39"
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

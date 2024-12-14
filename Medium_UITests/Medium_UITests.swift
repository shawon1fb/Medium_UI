//
//  Medium_UITests.swift
//  Medium_UITests
//
//  Created by shahanul on 11/18/24.
//

import Testing
@testable import Medium_UI

struct Medium_UITests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        
        let posts:[PostSingleItem] =  try await  MediumRepository().getMediumPosts(dto: MediumPostListDTO(variables: PostListVariables(paging: .init(to: nil, source: nil))))
        
        print("posts count \(posts.count)")
    }

}

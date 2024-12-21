//
//  PostDetailView.swift
//  Medium_UI
//
//  Created by shahanul on 12/14/24.
//

import SwiftUI

// PostDetailView.swift
struct PostDetailView: View {
    @Binding var post: PostSingleItem?

  var body: some View {
      VStack{
          if let post  = post{
              PostDetailConatiner(post: post)
          }else{
              ContentUnavailableView("Select a Post",
                  systemImage: "doc.text")
          }
      }
    
  }
}

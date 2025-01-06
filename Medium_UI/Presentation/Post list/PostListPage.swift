//
//  PostListPage.swift
//  Medium_UI
//
//  Created by shahanul on 12/13/24.
//

// ContentView.swift
import SwiftUI


struct TranslationDetailsView:View {
    let post: PostSingleItem
      
    @ObservedObject var postDetailsVM: PostDetailsViewModel
      
      init(post: PostSingleItem) {
          self.post = post
          _postDetailsVM = ObservedObject(wrappedValue: PostDetailsViewModelBindings().getDependencies(post: post))
      }
      
    var body: some View {
        VStack{
            if postDetailsVM.loading{
                ProgressView()
            }else{
                if let text = postDetailsVM.asText{
                    TranslationView(text: text)
                }else{
                    Text("text not found")
                }
                
            }
        }
    }
}

//
//  PostDetailsContainer.swift
//  Medium_UI
//
//  Created by shahanul on 12/16/24.
//

import SwiftUI
import EasyX
import XSwiftUI

struct PostDetailConatiner: View {
  let post: PostSingleItem
    
    @ObservedObject var postDetailsVM: PostDetailsViewModel
    
    init(post: PostSingleItem) {
        self.post = post
        _postDetailsVM = ObservedObject(wrappedValue: PostDetailsViewModelBindings().getDependencies(post: post))
    }
    
    
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text(post.title)
        Text(post.title)
          .font(.largeTitle)
          .bold()
         

        HStack {
          Text(post.creator.name)
            .foregroundColor(.secondary)
          Spacer()
          Text(post.firstPublishedAt.description)
            .foregroundColor(.secondary)
        }
        Divider()
          PostBodyContentView(post: post)
      }
        
     
      .padding()
      .textSelection(.enabled)

    }
    .frame(minWidth: 400)
  }
}



struct PostBodyContentView: View {
    let post: PostSingleItem
      
    @ObservedObject var viewModel: PostDetailsViewModel
      
      init(post: PostSingleItem) {
          self.post = post
          _viewModel = ObservedObject(wrappedValue: PostDetailsViewModelBindings().getDependencies(post: post))
      }
      
    
    var body: some View {
        VStack{
            if let hasError = viewModel.hasError{
                
                VStack{
                    Text(hasError)
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }else{
          
               
                Text(viewModel.title)
                    .font(.title)
                    .padding()
                Text(viewModel.subtitle)
                    .font(.subheadline)
                    .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.paragraphs) { paragraph in
                            ParagraphView(paragraph: paragraph)
                        }
                    }
                    .padding()
                }
            }
          
        }
        .onAppear(perform: {
            print("onAppear called for post \(post.id)")
        })
        .task {
            print("task called for post \(post.id)")
            await viewModel.getPostContentByID(postID: post.id)
        }
    }
}

struct PostDetailsBody:View {
    var body: some View {
        VStack{
            
        }
    }
}

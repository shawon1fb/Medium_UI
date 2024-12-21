//
//  PostListPage.swift
//  Medium_UI
//
//  Created by shahanul on 12/13/24.
//

// ContentView.swift
import SwiftUI

struct ContentView3: View {
    @StateObject private var viewModel = PostListViewModelBindings().getDependencies()
    @State  var selectedPost: PostSingleItem?
    @State var columnVisibility: NavigationSplitViewVisibility = .automatic
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            PostListView(posts: viewModel.posts, selectedPost: $selectedPost)
        } content: {
            if let post  = selectedPost{
                PostDetailConatiner(post: post)
            }else{
                ContentUnavailableView("Select a Post",
                    systemImage: "doc.text")
            }
        } detail: {
            if let _ = selectedPost {
                TranslationView(text: "Hello, how are you?")
            } else {
                ContentUnavailableView("Select a Post to View Translation",
                    systemImage: "doc.text.translation")
            }
        }
        .navigationSplitViewStyle(.prominentDetail)
        .navigationTitle("Medium")
        .task {
            await viewModel.fetchPosts()
        }
    }
}

#Preview(body: {
    ContentView3()
})

//
//  ContentView.swift
//  Medium_UI
//
//  Created by shahanul on 11/18/24.
//

import SwiftUI
import EasyX
import XSwiftUI

struct ContentView: View {
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
            if let post = selectedPost {
                TranslationDetailsView(post: post)
            } else {
                ContentUnavailableView("Select a Post to View Translation",
                    systemImage: "doc.text.translation")
            }
        }
        .navigationSplitViewStyle(.prominentDetail)
        .navigationTitle("Medium")
        .toolbar(content: {
            ThemeToggleButton()
        })
        .task {
            await viewModel.fetchPosts()
        }
    }
}

#Preview {
    ContentView()
}

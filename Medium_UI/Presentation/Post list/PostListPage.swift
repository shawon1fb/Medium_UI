//
//  PostListPage.swift
//  Medium_UI
//
//  Created by shahanul on 12/13/24.
//

// ContentView.swift
import SwiftUI

struct ContentView3: View {
    @StateObject private var viewModel = PostViewModel()
    @State private var selectedPost: PostListModel?
    @State var columnVisibility: NavigationSplitViewVisibility = .automatic
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            PostListView(posts: viewModel.posts, selectedPost: $selectedPost)
        } content: {
            if let post = selectedPost {
                PostDetailView(post: post)
//                ContentView2()
            } else {
                ContentUnavailableView("Select a Post",
                    systemImage: "doc.text")
            }
        } detail: {
            if let post = selectedPost {
                TranslationView()
            } else {
                ContentUnavailableView("Select a Post to View Translation",
                    systemImage: "doc.text.translation")
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// Models
struct PostListModel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let author: String
    let date: Date
    let content: String
    let readingTime: Int
    var isFeatured: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// ViewModel
class PostViewModel: ObservableObject {
    @Published var posts: [PostListModel] = []
    
    init() {
        loadPosts()
    }
    
    private func loadPosts() {
        // Simulate loading posts from an API
        posts = [
            PostListModel(title: "SwiftUI Best Practices",
                author: "John Doe",
                date: Date(),
                content: "SwiftUI revolutionizes the way we build apps...",
                readingTime: 5,
                isFeatured: true),
            PostListModel(title: "The Future of iOS Development",
                author: "Jane Smith",
                date: Date().addingTimeInterval(-86400),
                content: "As we look towards the future...",
                readingTime: 8,
                isFeatured: false)
        ]
    }
}

#Preview(body: {
    VStack{
        Image(systemName: "sidebar.left")
    }
})

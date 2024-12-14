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
//                PostDetailView(post: post)
                ContentView2()
            } else {
                ContentUnavailableView("Select a Post",
                    systemImage: "doc.text")
            }
        } detail: {
            if let post = selectedPost {
                TranslationView(originalContent: post.content)
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

// PostListView.swift
struct PostListView: View {
    let posts: [PostListModel]
    @Binding var selectedPost: PostListModel?
    
    var body: some View {
        List(posts, selection: $selectedPost) { post in
            PostRowView(post: post)
                .tag(post)
        }
        .navigationTitle("Posts")
        .listStyle(.inset)
    }
}

struct PostRowView: View {
    let post: PostListModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if post.isFeatured {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
                Text(post.title)
                    .font(.headline)
            }
            
            HStack {
                Text(post.author)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(post.readingTime) min read")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// PostDetailView.swift
struct PostDetailView: View {
    let post: PostListModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(post.title)
                    .font(.largeTitle)
                    .bold()
                
                HStack {
                    Text(post.author)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(post.date, style: .date)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                Text(post.content)
                    .lineSpacing(8)
            }
            .padding()
        }
        .navigationTitle("Article")
        .frame(minWidth: 400)
    }
}
struct TranslationView: View {
    let originalContent: String
    @State private var selectedLanguage = "Spanish"
    @State private var isExpanded = true
    @State private var isSplitViewCollapsed = true
    let availableLanguages = ["Spanish", "French", "German", "Chinese"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Custom toolbar with split view toggle
            HStack {
                Button(action: {
                    isSplitViewCollapsed.toggle()
                }) {
                    Image(systemName: isSplitViewCollapsed ? "rectangle.portrait.leftthird.inset.filled" : "rectangle.portrait.leftthird.inset")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
                .help("Toggle Translation Panel")
                
                Spacer()
            }
            .padding(.bottom, 8)
            .frame(width: 50, height: 50)
            
            VStack{
                // Translation content
                if !isSplitViewCollapsed {
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("Translation Language", selection: $selectedLanguage) {
                            ForEach(availableLanguages, id: \.self) { language in
                                Text(language).tag(language)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        ScrollView {
                            Text("Translated content would appear here...")
                                .lineSpacing(8)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .navigationTitle("Translation")
        .frame(minWidth: 300)
        .animation(.easeInOut, value: isSplitViewCollapsed)
    }
}


#Preview(body: {
    VStack{
        Image(systemName: "sidebar.left")
    }
})

//
//  PostListView.swift
//  Medium_UI
//
//  Created by shahanul on 12/14/24.
//

import SwiftUI

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

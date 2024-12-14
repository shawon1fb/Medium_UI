//
//  PostListView.swift
//  Medium_UI
//
//  Created by shahanul on 12/14/24.
//

import SwiftUI

// PostListView.swift
struct PostListView: View {
    let posts: [PostSingleItem]
    @Binding var selectedPost: PostSingleItem?
    
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
    let post: PostSingleItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if post.isLocked {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
                Text(post.title)
                    .font(.headline)
            }
            
            HStack {
                Text(post.creator.name)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(post.readingTime.int) min read")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

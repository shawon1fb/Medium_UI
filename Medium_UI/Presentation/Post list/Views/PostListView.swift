//
//  PostListView.swift
//  Medium_UI
//
//  Created by shahanul on 12/14/24.
//

import SwiftUI
import XSwiftUI
import EasyX

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
        HStack{
            MediaView(model: .image(url: post.previewImage.imageURL.absoluteString))
                .frame(width: 160, height: 160)
                .cornerRadius(8, corners: .allCorners)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if post.isLocked {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Member Only")
                            .font(.system(size: 12, weight: .semibold))
                    }else{
                        Text("Public")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    
                }
                
                Text(post.title)
                    .font(.system(size: 20, weight: .semibold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                Text(post.extendedPreviewContent.subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                HStack {
                    Text(post.creator.name)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(post.readingTime.int) min read")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 8)
            
           
        }
        .padding(.vertical, 4)
    }
}

//
//  IMediumRepository.swift
//  Medium_UI
//
//  Created by shahanul on 12/16/24.
//

import Foundation

protocol IMediumRepository {
    
    func getMediumPosts(dto : MediumPostListDTO) async throws-> [PostSingleItem]
    func getPostByID(postID: String)async throws->Post
    func getPostByURL(postURL: String)async throws->Post
}

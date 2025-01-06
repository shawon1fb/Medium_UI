//
//  PostListViewModel.swift
//  Medium_UI
//
//  Created by shahanul on 12/14/24.
//

import Foundation
import SwiftUI
import Combine
import XSwiftUI
import EasyX


final class PostListViewModelBindings{
    
    func getDependencies() -> PostListViewModel {
        if let viewModel = try? DIContainer.shared.resolve(PostListViewModel.self) {
            return viewModel
        }
        
        let viewModel = PostListViewModel()
        DIContainer.shared.register(PostListViewModel.self, factory: { _ in viewModel})
        
        return viewModel
    }
    
}

// ViewModel
final class PostListViewModel: ObservableObject {
    @Published var posts: [PostSingleItem] = []
    let repository: MediumPostRepository
    
    init( repository: MediumPostRepository = MediumPostRepositoryBindings().getDependencies()) {
        self.repository = repository
    }
    
    
    @MainActor
    func fetchPosts() async{
        
        do{
            
            let post = try await repository.getMediumPosts(dto: .init(variables: .init(paging: .init(to: nil, source: nil))))
            
            self.posts = post
        }catch{
            print("post error \(error)")
        }
    }
}

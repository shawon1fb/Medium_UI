//
//  PostDetailsViewModel.swift
//  Medium_UI
//
//  Created by shahanul on 12/16/24.
//

import EasyX
import Foundation
import MediumCore
import SwiftUI
import XSwiftUI

#if canImport(UIKit)
  import UIKit
//typealias FontType = UIFont
#else
  import AppKit
//typealias FontType = NSFont
#endif

final class PostDetailsViewModelBindings {
  func getDependencies(post: PostSingleItem) -> PostDetailsViewModel {

      print("new view model for \(post.id)")
    if let viewModel = try? DIContainer.shared.resolve(PostDetailsViewModel.self, name: post.id) {
      return viewModel
    } else {
      let repository = MediumPostRepositoryBindings().getDependencies()
        let viewModel = PostDetailsViewModel(repository: repository, postID: post.id)

      DIContainer.shared.register(
        PostDetailsViewModel.self, name: post.id, factory: { _ in viewModel })
      return viewModel
    }

  }
}

class PostDetailsViewModel: ObservableObject {
  @Published var paragraphs: [ParsedParagraph] = []
  @Published var title: String = ""
  @Published var subtitle: String = ""
  let repository: IMediumRepository
  @Published var previewImageId: String = ""
  @Published var highlights: [HighlightModel] = []
  @Published var tags: [PostTag] = []

  @Published var hasError: String? = nil
    @Published var loading: Bool = false

    init(repository: IMediumRepository, postID: String) {
    self.repository = repository
        Task{
           await getPostContentByID(postID: postID)
        }
  }

  @MainActor
  func getPostContentByID(postID: String) async {
    do {
        loading = true
      hasError = nil
        print("postid \(postID)")
      let post = try await repository.getPostByID(postID: postID)
      title = post.title
      subtitle = post.previewContent.subtitle
      previewImageId =  "" //post.previewImage.id

      highlights = post.highlights
      tags = post.tags.map({ .init(displayTitle: $0.displayTitle) })
        print("paragraphs -> \(post.content.bodyModel.paragraphs.count)")
        
        paragraphs = MediumPostParseContent.parseContent(post.content, title: title, subtitle: subtitle, previewImageId: previewImageId, tags: tags, highlights: highlights)
        
          print("after parsing -> \(paragraphs.count)")

        loading = false
    } catch {
      print("error fetching post: \(error)")
      hasError = error.localizedDescription
        loading = false
    }
  }
}

//
//  PostDetailView.swift
//  Medium_UI
//
//  Created by shahanul on 12/14/24.
//

import SwiftUI

// PostDetailView.swift
struct PostDetailView: View {
    @Binding var post: PostSingleItem?

  var body: some View {
      VStack{
          if let post  = post{
              PostDetailConatiner(post: post)
          }else{
              ContentUnavailableView("Select a Post",
                  systemImage: "doc.text")
          }
      }
    
  }
}

struct TranslationView: View {
 
  @State private var selectedLanguage = "Spanish"
  @State private var isExpanded = true
  @State private var isSplitViewCollapsed = true
  let availableLanguages = ["Spanish", "French", "German", "Chinese"]

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {

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
      .padding()
      .navigationTitle("Translation")
      .frame(minWidth: 300)
      .animation(.easeInOut, value: isSplitViewCollapsed)
    }
  }
}

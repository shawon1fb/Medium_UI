//
//  CodeBlockView.swift
//  Medium_UI
//
//  Created by shahanul on 11/21/24.
//

import SwiftUI
import XSwiftUI
import EasyX
import HighlightSwift

struct CodeBlockView: View {
    let paragraph: Paragraph
    
    var body: some View {
        CodeBlock(language: paragraph.codeBlockMetadata?.lang, text: paragraph.text)
       
    }
}


struct CodeBlock:View {
    let language: String?
    let text: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let lang = language {
                Text(lang)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            
                CodeBlockView2(code: text ?? "", lang: lang)
            }
        }
        .background(Color(hex: "#111827"))
        .cornerRadius(8)
        .padding(.vertical, 8)
    }
}
struct CodeBlockView2: View {
    var code: String
    var lang: String
    @State var attributedText:AttributedString = ""
    let highlight = Highlight()
    var body: some View {
        ScrollView(.horizontal) {
//            Text(attributedString(for: code))
            Text(attributedText)
                .font(.system(.body, design: .monospaced))
                .padding()
        }
        .padding(.horizontal)
        .onAppear{
            Task{
                do{
                    let result: HighlightResult = try await highlight.request(code)
                    print(result)
                    
                    attributedText = result.attributedText
                }catch{
                    print(error)
                }
            }
        }
    }
}

#Preview(body: {
    CodeBlockView2(code: """
               struct Person {
                   let name: String
                   var age: Int
                   func greet() {
                       print("Hello, \\\\\\\\(name)!")
                   }
               }
               """ , lang: "swift")
})

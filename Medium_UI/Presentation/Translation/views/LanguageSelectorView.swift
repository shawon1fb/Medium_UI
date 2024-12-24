//
//  LanguageSelectorView.swift
//  Medium_UI
//
//  Created by Shahanul Haque on 12/25/24.
//

import SwiftUI
// MARK: - Language Selector View
struct LanguageSelectorView: View {
    @Binding var selectedLanguage: Language
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "globe")
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Select Language")
                    .font(.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
            }
            
            Menu {
                ForEach(Language.allCases, id: \.self) { language in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedLanguage = language
                        }
                    }) {
                        HStack {
                            Text(language.description)
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            Spacer()
                            if selectedLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                       
                    }
                    .buttonStyle(.plain)
                }
            } label: {
                HStack {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Text(selectedLanguage.flag)
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Text(selectedLanguage.rawValue)
                            .font(.body.weight(.medium))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .padding(DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DesignSystem.Colors.cardBackground)
                        .shadow(color: Color.black.opacity(0.05), radius: 4)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
}

// MARK: - Usage Example
struct LanguageSelectorViewPreview: View {
    @State private var selectedLanguage: Language = .english
    
    var body: some View {
        LanguageSelectorView(selectedLanguage: $selectedLanguage)
    }
}
#Preview(body: {
    LanguageSelectorViewPreview()
})

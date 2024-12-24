import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct TranslationView: View {
    @StateObject private var viewModel: TranslationViewModel
    let text: String
    @State private var currentTask: Task<Void, Never>?
    @State private var copiedOriginal: Bool = false
    @State private var copiedTranslated: Bool = false
    @State private var copiedTokenCount: Bool = false
    @State private var translationStartTime: Date?
    @State private var translationDuration: TimeInterval = 0
    @State private var copiedDuration: Bool = false
    
    init(text: String) {
        self._viewModel = StateObject(
            wrappedValue: TranslationViewModelBindings().getDependencies()
        )
        self.text = text
    }
    
    // Calculate token size for Ollama
    private func calculateTokenCount(for text: String) -> Int {
        // Simple approximation: split on whitespace and punctuation
        let components = text.components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        
        // Apply a multiplier to account for special tokens and subword tokenization
        return Int(Double(components.count) * 1.3)
    }
    
    private func copyToClipboard(_ text: String, copied: Binding<Bool>) {
        #if os(iOS)
            UIPasteboard.general.string = text
        #elseif os(macOS)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
        #endif
        
        withAnimation {
            copied.wrappedValue = true
        }
        // Reset copy state after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                copied.wrappedValue = false
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Language selector
            Picker("Select Language", selection: $viewModel.selectedLanguage) {
                ForEach(Language.allCases, id: \.self) { language in
                    Text(language.rawValue)
                        .tag(language)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .onChange(of: viewModel.selectedLanguage) { _ in
                currentTask?.cancel()
                translationStartTime = Date()
                currentTask = Task {
                    await viewModel.translate(text: text)
                    if let startTime = translationStartTime {
                        translationDuration = Date().timeIntervalSince(startTime)
                    }
                }
            }
            
            // Token Count and Translation Time Display
            VStack(spacing: 8) {
                HStack {
                    Text("Estimated Tokens: \(calculateTokenCount(for: text))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        copyToClipboard("\(calculateTokenCount(for: text))", copied: $copiedTokenCount)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: copiedTokenCount ? "checkmark" : "doc.on.doc")
                            Text(copiedTokenCount ? "Copied!" : "Copy")
                        }
                        .foregroundColor(copiedTokenCount ? .green : .blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                // Translation Time Display
                HStack {
                    Text("Translation Time: \(String(format: "%.2f", translationDuration))s")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        copyToClipboard("\(String(format: "%.2f", translationDuration))", copied: $copiedDuration)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: copiedDuration ? "checkmark" : "doc.on.doc")
                            Text(copiedDuration ? "Copied!" : "Copy")
                        }
                        .foregroundColor(copiedDuration ? .green : .blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack {
                    // Original text card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Original Text")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button(action: {
                                copyToClipboard(viewModel.originalText, copied: $copiedOriginal)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: copiedOriginal ? "checkmark" : "doc.on.doc")
                                    Text(copiedOriginal ? "Copied!" : "Copy")
                                }
                                .foregroundColor(copiedOriginal ? .green : .blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        Group {
                            if viewModel.originalText.isEmpty {
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 100)
                            } else {
                                Text(viewModel.originalText)
                                    .font(.body)
                                    .lineLimit(5)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.background)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    
                    // Translated text card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Translated Text")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button(action: {
                                copyToClipboard(viewModel.translatedText, copied: $copiedTranslated)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: copiedTranslated ? "checkmark" : "doc.on.doc")
                                    Text(copiedTranslated ? "Copied!" : "Copy")
                                }
                                .foregroundColor(copiedTranslated ? .green : .blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        Group {
                            if viewModel.translatedText.isEmpty {
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 100)
                            } else {
                                Text(viewModel.translatedText)
                                    .font(.body)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.background)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                }
            }
            
            // Control Buttons
            if viewModel.isTranslating {
                Button(action: {
                    currentTask?.cancel()
                    if let startTime = translationStartTime {
                        translationDuration = Date().timeIntervalSince(startTime)
                    }
                    Task {
                        await viewModel.stopTranslation()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Stop Translation")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .scaleEffect(1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: viewModel.isTranslating)
            } else {
                Button(action: {
                    currentTask?.cancel()
                    translationStartTime = Date()
                    currentTask = Task {
                        await viewModel.translate(text: text)
                        if let startTime = translationStartTime {
                            translationDuration = Date().timeIntervalSince(startTime)
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Regenerate Translation")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .scaleEffect(1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: !viewModel.isTranslating)
            }
        }
        .padding(.vertical)
        .task {
            translationStartTime = Date()
            currentTask = Task {
                await viewModel.translate(text: text)
                if let startTime = translationStartTime {
                    translationDuration = Date().timeIntervalSince(startTime)
                }
            }
        }
        .onDisappear {
            currentTask?.cancel()
        }
    }
}

struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView(text: "Hello, how are you?")
    }
}

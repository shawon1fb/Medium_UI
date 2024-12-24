// MARK: - Domain Layer
import SwiftUI

// MARK: - Data Layer





// MARK: - View Layer
struct TranslationView: View {
    @StateObject private var viewModel: TranslationViewModel
    let text: String
    
    init(text: String) {
        self._viewModel = StateObject(
            wrappedValue: TranslationViewModelBindings().getDependencies()
        )
        self.text = text
        
        TranslationViewModelBindings().getDependencies().translate(text: text)
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
                viewModel.translate(text: text)
            }
            
            ScrollView {
                VStack {
                    
                    
                    // Translated text card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Original Text")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Group {
                            if viewModel.originalText.isEmpty {
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 100)
                            } else {
                                Text(viewModel.originalText)
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
                    
                    // Translated text card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Translated Text")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
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
            
            Text("is translating \(viewModel.isTranslating ? "true" : "false")")
            // Control Buttons
            if viewModel.isTranslating {
                Button(action: {
                    viewModel.stopTranslation()
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
                    viewModel.translate(text: text)
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
        .onAppear {
            viewModel.translate(text: text)
        }
    }
}

// MARK: - Preview Provider
struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView(text: "Hello, how are you?")
    }
}

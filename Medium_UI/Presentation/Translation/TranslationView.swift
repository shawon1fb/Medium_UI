// MARK: - Domain Layer
import SwiftUI
// Translation Protocol (Interface Segregation Principle)
protocol TranslationService {
    func translate(text: String, from: Language, to: Language) async throws -> AsyncStream<String>
}

// Entity
enum Language: String, CaseIterable {
    case english = "English"
    case bangla = "বাংলা"
    
    var code: String {
        switch self {
        case .english: return "en"
        case .bangla: return "bn"
        }
    }
}

// MARK: - Data Layer

// Repository Implementation (Dependency Inversion Principle)
class OllamaTranslationRepository: TranslationService {
//    private let baseURL = "http://localhost:11434/api/generate"
    private let baseURL = "http://192.168.0.213:11434/api/generate"
    private let model = "llama3.1:latest"
    
    func translate(text: String, from: Language, to: Language) async throws -> AsyncStream<String> {
        print("translate called with \(text), \(from), \(to)")
        return AsyncStream { continuation in
            Task {
                let prompt = """
                Translate the following text from \(from.code) to \(to.code):
                "\(text)"
                Only provide the translation, no explanations.
                """
                
                let body: [String: Any] = [
                    "model": model,
                    "prompt": prompt,
                    "stream": true
                ]
                
                guard let url = URL(string: baseURL),
                      let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
                    continuation.finish()
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                do {
                    let (stream, _) = try await URLSession.shared.bytes(for: request)
                    
                    for try await line in stream.lines {
                        guard let data = line.data(using: .utf8),
                              let response = try? JSONDecoder().decode(OllamaResponse.self, from: data) else {
                            continue
                        }
                        continuation.yield(response.response)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
        }
    }
}

// Response Model
struct OllamaResponse: Codable {
    let response: String
}

// MARK: - Presentation Layer

// ViewModel (Single Responsibility Principle)
@MainActor
class TranslationViewModel: ObservableObject {
    private let translationService: TranslationService
    
    @Published var originalText: String = ""
    @Published var translatedText: String = ""
    @Published var selectedLanguage: Language = .bangla
    @Published var isTranslating: Bool = false
    
    init(translationService: TranslationService) {
        self.translationService = translationService
    }
    
    func translate(text: String) {
        guard !text.isEmpty else { return }
        
        Task {
            isTranslating = true
            translatedText = ""
            
            do {
                let stream = try await translationService.translate(
                    text: text,
                    from: .english,
                    to: selectedLanguage
                )
                
                for await translation in stream {
                    translatedText += translation
                }
            } catch {
                // Handle error appropriately
                print("Translation error: \(error)")
            }
            
            isTranslating = false
        }
    }
}

// MARK: - View Layer
struct TranslationView: View {
    @StateObject private var viewModel: TranslationViewModel
    let text: String
    
    init(text: String) {
        self._viewModel = StateObject(
            wrappedValue: TranslationViewModel(
                translationService: OllamaTranslationRepository()
            )
        )
        self.text = text
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
            
            // Original text card
            VStack(alignment: .leading, spacing: 8) {
                Text("Original Text")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(text)
                    .font(.body)
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
                    if viewModel.isTranslating {
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

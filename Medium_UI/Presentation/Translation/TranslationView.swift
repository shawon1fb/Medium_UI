import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif



// MARK: - Design System
enum DesignSystem {
    enum Colors {
        static let primaryGradient = LinearGradient(
            colors: [Color(hex: "6366F1"), Color(hex: "4F46E5")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let secondaryGradient = LinearGradient(
            colors: [Color(hex: "EC4899"), Color(hex: "BE185D")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let surfaceBackground = Color(hex: "F8FAFC")
        static let cardBackground = Color.white
        static let textPrimary = Color(hex: "1E293B")
        static let textSecondary = Color(hex: "64748B")
    }
    
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
    }
    
    struct Shadows {
        static func card() -> some View {
            return Color.black.opacity(0.05)
                .shadow(radius: 15, x: 0, y: 5)
        }
        
        static func button() -> some View {
            return Color.black.opacity(0.1)
                .shadow(radius: 10, x: 0, y: 4)
        }
    }
}

// MARK: - Custom Views
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(DesignSystem.Spacing.lg)
            .background(
                DesignSystem.Colors.cardBackground
                    .opacity(0.98)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
    }
}

struct AnimatedButton: View {
    let title: String
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 8)
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Main View
struct TranslationView: View {
    @StateObject private var viewModel: TranslationViewModel
    let text: String
    
    // MARK: - State Properties
    @State private var currentTask: Task<Void, Never>?
    @State private var copiedStates: [CopyState: Bool] = [:]
    @State private var translationStartTime: Date?
    @State private var translationDuration: TimeInterval = 0
    @State private var timer: Timer? = nil
    
    enum CopyState: String {
        case original, translated, tokenCount, duration
    }
    
    init(text: String) {
        self._viewModel = StateObject(
            wrappedValue: TranslationViewModelBindings().getDependencies()
        )
        self.text = text
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        translationStartTime = Date()
        translationDuration = 0
        
        // Invalidate any existing timer first
        timer?.invalidate()
        
        // Create a new timer that fires every 0.1 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = translationStartTime {
                // Update the duration on the main thread to ensure UI updates
                DispatchQueue.main.async {
                    
                    translationDuration = Date().timeIntervalSince(startTime)
                    
                    print("translationDuration \(translationDuration)")
                }
            }
        }
        
        // Make sure the timer runs even when scrolling
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        // Keep the final duration
        if let startTime = translationStartTime {
            translationDuration = Date().timeIntervalSince(startTime)
        }
        translationStartTime = nil
    }
    
    // MARK: - Helper Functions
    private func calculateTokenCount(for text: String) -> Int {
        // Simple approximation: split on whitespace and punctuation
        let components = text.components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        
        // Apply a multiplier to account for special tokens and subword tokenization
        return Int(Double(components.count) * 1.3)
    }

    private func copyToClipboard(_ text: String, state: CopyState) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
        
        withAnimation {
            copiedStates[state] = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                copiedStates[state] = false
            }
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func makeLanguageSelector() -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("Translation Language")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Picker("Language", selection: $viewModel.selectedLanguage) {
                ForEach(Language.allCases, id: \.self) { language in
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: languageIcon(for: language))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Text(language.rawValue)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .tag(language)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
          
            .padding(DesignSystem.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private func languageIcon(for language: Language) -> String {
        switch language {
        case .english:
            return "character.book.closed.fill"
        case .bangla:
            return "globe.asia.australia.fill"
        }
    }
    
    
    
    @ViewBuilder
    private func makeMetricsView() -> some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Token Count
            MetricCard(
                title: "Estimated Tokens",
                value: "\(calculateTokenCount(for: text))",
                icon: "number.circle.fill",
                state: .tokenCount,
                copyAction: copyToClipboard
            )
            
            // Translation Time
            MetricCard(
                title: "Translation Time",
                value: String(format: "%.1fs", translationDuration),
                icon: "clock.fill",
                state: .duration,
                copyAction: copyToClipboard
            )
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    @ViewBuilder
    private func makeTranslationCard(
        title: String,
        text: String,
        isEmpty: Bool,
        copyState: CopyState
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    CopyButton(
                        text: text,
                        state: copyState,
                        isCopied: copiedStates[copyState] ?? false,
                        copyAction: copyToClipboard
                    )
                }
                
                if isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 100)
                } else {
                    Text(text)
                        .font(.body)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                makeLanguageSelector()
                    .onChange(of: viewModel.selectedLanguage) { _ in
                        handleTranslationStart()
                    }
                
                makeMetricsView()
                
//                makeTranslationCard(
//                    title: "Original Text",
//                    text: viewModel.originalText,
//                    isEmpty: viewModel.originalText.isEmpty,
//                    copyState: .original
//                )
                
                makeTranslationCard(
                    title: "Translated Text",
                    text: viewModel.translatedText,
                    isEmpty: viewModel.translatedText.isEmpty,
                    copyState: .translated
                )
                
                if viewModel.isTranslating {
                    AnimatedButton(
                        title: "Stop Translation",
                        icon: "stop.fill",
                        gradient: DesignSystem.Colors.secondaryGradient
                    ) {
                        handleTranslationStop()
                    }
                } else {
                    AnimatedButton(
                        title: "Regenerate Translation",
                        icon: "arrow.clockwise",
                        gradient: DesignSystem.Colors.primaryGradient
                    ) {
                        handleTranslationStart()
                    }
                }
            }
            .padding(.vertical, DesignSystem.Spacing.xl)
        }
        .background(DesignSystem.Colors.surfaceBackground)
        .task {
            handleTranslationStart()
        }
        .onDisappear {
            handleCleanup()
        }
    }
    
    // MARK: - Action Handlers
    private func handleTranslationStart() {
        currentTask?.cancel()
        translationStartTime = Date()
        startTimer()
        
        currentTask = Task {
            await viewModel.translate(text: text)
            stopTimer()
            if let startTime = translationStartTime {
                translationDuration = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    private func handleTranslationStop() {
        currentTask?.cancel()
        if let startTime = translationStartTime {
            translationDuration = Date().timeIntervalSince(startTime)
        }
        Task {
            await viewModel.stopTranslation()
        }
        stopTimer()
    }
    
    private func handleCleanup() {
        currentTask?.cancel()
        stopTimer()
    }
}

// MARK: - Supporting Views
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let state: TranslationView.CopyState
    let copyAction: (String, TranslationView.CopyState) -> Void
    
    var body: some View {
        GlassCard {
            VStack(spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                copyAction(value, state)
            }
        }
    }
}

struct CopyButton: View {
    let text: String
    let state: TranslationView.CopyState
    let isCopied: Bool
    let copyAction: (String, TranslationView.CopyState) -> Void
    
    var body: some View {
        Button(action: {
            copyAction(text, state)
        }) {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                Text(isCopied ? "Copied!" : "Copy  ")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(isCopied ? .green : DesignSystem.Colors.textSecondary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(Color.secondary.opacity(0.1))
            .clipShape(Capsule())
        }
    }
}

// MARK: - Color Extensions
extension Color {
    init(nsColor: NSColor) {
        #if os(iOS)
        self.init(uiColor: UIColor.systemBackground)
        #elseif os(macOS)
        self.init(nsColor)
        #endif
    }
    
    static var systemBackground: Color {
        #if os(iOS)
        return Color(uiColor: .systemBackground)
        #elseif os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #endif
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView(text: "Hello, how are you?")
    }
}

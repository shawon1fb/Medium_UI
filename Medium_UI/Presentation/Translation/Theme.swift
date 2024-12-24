//
//  Theme.swift
//  Medium_UI
//
//  Created by Shahanul Haque on 12/25/24.
//
import SwiftUI
// MARK: - Theme Protocol
protocol Theme {
    var primaryGradient: LinearGradient { get }
    var secondaryGradient: LinearGradient { get }
    var surfaceBackground: Color { get }
    var cardBackground: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
}

// MARK: - Theme Implementations
struct LightTheme: Theme {
    let primaryGradient = LinearGradient(
        colors: [Color(hex: "6366F1"), Color(hex: "4F46E5")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    let secondaryGradient = LinearGradient(
        colors: [Color(hex: "EC4899"), Color(hex: "BE185D")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    let surfaceBackground = Color(hex: "F8FAFC")
    let cardBackground = Color.white
    let textPrimary = Color(hex: "1E293B")
    let textSecondary = Color(hex: "64748B")
}

struct DarkTheme: Theme {
    let primaryGradient = LinearGradient(
        colors: [Color(hex: "818CF8"), Color(hex: "6366F1")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    let secondaryGradient = LinearGradient(
        colors: [Color(hex: "F472B6"), Color(hex: "EC4899")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    let surfaceBackground = Color(hex: "0F172A")
    let cardBackground = Color(hex: "1E293B")
    let textPrimary = Color.white
    let textSecondary = Color(hex: "94A3B8")
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published private(set) var currentTheme: Theme
    
    static let shared = ThemeManager()
    
    private init() {
        self.currentTheme = LightTheme()
    }
    
    func setTheme(_ theme: Theme) {
        currentTheme = theme
    }
}




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

// MARK: - Theme Environment Key
private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = LightTheme()
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Theme Toggle Button
struct ThemeToggleButton: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating = false
    
    private var iconRotation: Double {
        themeManager.currentTheme is LightTheme ? 0 : 180
    }
    
    private var accessibilityLabel: String {
        themeManager.currentTheme is LightTheme ?
            "Switch to dark theme" : "Switch to light theme"
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                isAnimating = true
                HapticManager.impact()
                themeManager.setTheme(
                    themeManager.currentTheme is LightTheme ?
                        DarkTheme() : LightTheme()
                )
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isAnimating = false
            }
        }) {
            ZStack {
                themeManager.currentTheme.secondaryGradient
                    .opacity(0.9)
                    .blur(radius: 0.5)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: themeManager.currentTheme is LightTheme ?
                            "moon.stars.fill" : "sun.max.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .rotationEffect(.degrees(iconRotation))
                            .scaleEffect(isAnimating ? 1.2 : 1)
                            .animation(.spring(response: 0.35, dampingFraction: 0.6),
                                     value: iconRotation)
                    }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            .scaleEffect(isAnimating ? 0.95 : 1)
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to toggle theme")
    }
}
struct HapticManager {
    static func impact() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .default)
        #endif
    }
}

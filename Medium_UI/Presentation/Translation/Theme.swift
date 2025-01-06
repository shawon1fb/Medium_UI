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
   var accent: Color { get }
   var success: Color { get }
   var warning: Color { get }
   var error: Color { get }
   var divider: Color { get }
   var elevation: [Color] { get }
   var primaryButtonBackground: LinearGradient { get }
   var secondaryButtonBackground: Color { get }
   var inputBackground: Color { get }
   var inputBorder: Color { get }
   var shadow: Color { get }
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
   let accent = Color(hex: "6366F1")
   let success = Color(hex: "22C55E")
   let warning = Color(hex: "F59E0B")
   let error = Color(hex: "EF4444")
   let divider = Color(hex: "E2E8F0")
   let elevation: [Color] = [
       Color(hex: "FFFFFF"),
       Color(hex: "F8FAFC"),
       Color(hex: "F1F5F9")
   ]
   let primaryButtonBackground = LinearGradient(
       colors: [Color(hex: "6366F1"), Color(hex: "4F46E5")],
       startPoint: .leading,
       endPoint: .trailing
   )
   let secondaryButtonBackground = Color(hex: "F1F5F9")
   let inputBackground = Color(hex: "F8FAFC")
   let inputBorder = Color(hex: "E2E8F0")
   let shadow = Color.black.opacity(0.1)
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
   let accent = Color(hex: "818CF8")
   let success = Color(hex: "4ADE80")
   let warning = Color(hex: "FCD34D")
   let error = Color(hex: "F87171")
   let divider = Color(hex: "334155")
   let elevation: [Color] = [
       Color(hex: "1E293B"),
       Color(hex: "0F172A"),
       Color(hex: "020617")
   ]
   let primaryButtonBackground = LinearGradient(
       colors: [Color(hex: "818CF8"), Color(hex: "6366F1")],
       startPoint: .leading,
       endPoint: .trailing
   )
   let secondaryButtonBackground = Color(hex: "334155")
   let inputBackground = Color(hex: "1E293B")
   let inputBorder = Color(hex: "334155")
   let shadow = Color.black.opacity(0.2)
}

// MARK: - Design System
enum DesignSystem {
   enum Spacing {
       static let xxs: CGFloat = 4
       static let xs: CGFloat = 8
       static let sm: CGFloat = 12
       static let md: CGFloat = 16
       static let lg: CGFloat = 24
       static let xl: CGFloat = 32
       static let xxl: CGFloat = 40
   }
   
   enum CornerRadius {
       static let sm: CGFloat = 4
       static let md: CGFloat = 8
       static let lg: CGFloat = 12
       static let xl: CGFloat = 16
       static let pill: CGFloat = 9999
   }
   
   enum FontSize {
       static let xs: CGFloat = 12
       static let sm: CGFloat = 14
       static let md: CGFloat = 16
       static let lg: CGFloat = 18
       static let xl: CGFloat = 20
       static let xxl: CGFloat = 24
       static let display: CGFloat = 32
   }
   
   enum Shadows {
       static func card() -> some View {
           Color.black.opacity(0.05)
               .shadow(radius: 15, x: 0, y: 5)
       }
       
       static func button() -> some View {
           Color.black.opacity(0.1)
               .shadow(radius: 10, x: 0, y: 4)
       }
   }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
   @Published private(set) var currentTheme: Theme
   @Published private(set) var isDarkMode: Bool = false
   
   static let shared = ThemeManager()
   
   private init() {
       self.currentTheme = LightTheme()
   }
   
   func toggleTheme() {
       isDarkMode.toggle()
       currentTheme = isDarkMode ? DarkTheme() : LightTheme()
   }
   
   func setTheme(_ theme: Theme) {
       currentTheme = theme
   }
}

struct CardStyle: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .background(themeManager.currentTheme.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .shadow(color: themeManager.currentTheme.shadow, radius: 10, x: 0, y: 4)
    }
}

struct PrimaryButtonStyle: ViewModifier {
   @EnvironmentObject var themeManager: ThemeManager
   let isEnabled: Bool
   
   init(isEnabled: Bool = true) {
       self.isEnabled = isEnabled
   }
   
   func body(content: Content) -> some View {
       content
           .background(themeManager.currentTheme.primaryButtonBackground)
           .opacity(isEnabled ? 1 : 0.6)
           .foregroundColor(.white)
           .cornerRadius(DesignSystem.CornerRadius.md)
           .shadow(color: themeManager.currentTheme.shadow, radius: 8, x: 0, y: 4)
   }
}

struct SecondaryButtonStyle: ViewModifier {
   @EnvironmentObject var themeManager: ThemeManager
   let isEnabled: Bool
   
   init(isEnabled: Bool = true) {
       self.isEnabled = isEnabled
   }
   
   func body(content: Content) -> some View {
       content
           .background(themeManager.currentTheme.secondaryButtonBackground)
           .opacity(isEnabled ? 1 : 0.6)
           .foregroundColor(themeManager.currentTheme.textPrimary)
           .cornerRadius(DesignSystem.CornerRadius.md)
   }
}

struct InputFieldStyle: ViewModifier {
   @EnvironmentObject var themeManager: ThemeManager
   
   func body(content: Content) -> some View {
       content
           .padding()
           .background(themeManager.currentTheme.inputBackground)
           .cornerRadius(DesignSystem.CornerRadius.md)
           .overlay(
               RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                   .stroke(themeManager.currentTheme.inputBorder, lineWidth: 1)
           )
   }
}

// MARK: - View Extensions
extension View {
   func cardStyle() -> some View {
       modifier(CardStyle())
   }
   
   func primaryButtonStyle(isEnabled: Bool = true) -> some View {
       modifier(PrimaryButtonStyle(isEnabled: isEnabled))
   }
   
   func secondaryButtonStyle(isEnabled: Bool = true) -> some View {
       modifier(SecondaryButtonStyle(isEnabled: isEnabled))
   }
   
   func inputFieldStyle() -> some View {
       modifier(InputFieldStyle())
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
                Color(hex: "4DA1A9")
                    .opacity(0.9)
                    .blur(radius: 0.5)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                
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
           
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            .scaleEffect(isAnimating ? 0.95 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to toggle theme")
        .environment(\.colorScheme, themeManager.isDarkMode  == false ? .light : .dark)
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

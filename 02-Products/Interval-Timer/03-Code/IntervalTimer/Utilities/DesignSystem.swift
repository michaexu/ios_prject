// DesignSystem.swift
// 设计系统 - 定义颜色、字体、间距等设计规范

import SwiftUI

// MARK: - 颜色系统
extension Color {
    // 背景色
    static let backgroundDeep = Color(hex: "0A0E27")
    static let backgroundLight = Color(hex: "151B3D")
    
    // 霓虹色
    static let neonBlue = Color(hex: "00D9FF")
    static let neonGreen = Color(hex: "00FF88")
    static let neonPurple = Color(hex: "B44AFF")
    
    // 功能色
    static let alertRed = Color(hex: "FF3B5C")
    
    // 文字色
    static let textPrimary = Color(hex: "FFFFFF")
    static let textSecondary = Color(hex: "8E9AAF")
    static let textDisabled = Color(hex: "4A5568")
    
    // 从十六进制初始化
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
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 渐变
extension LinearGradient {
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [Color.neonBlue, Color.neonGreen]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let purpleBlueGradient = LinearGradient(
        gradient: Gradient(colors: [Color.neonPurple, Color.neonBlue]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - 字体系统
extension Font {
    static let appLargeTitle = Font.system(size: 34, weight: .bold)
    static let appTitle = Font.system(size: 28, weight: .bold)
    static let appSubtitle = Font.system(size: 22, weight: .semibold)
    static let appBody = Font.system(size: 17, weight: .regular)
    static let appCaption = Font.system(size: 15, weight: .regular)
    static let appSmall = Font.system(size: 13, weight: .regular)
    static let appTimer = Font.system(size: 72, weight: .bold)
}

// MARK: - 间距系统
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - 圆角
struct CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let circle: CGFloat = 50
}

// MARK: - 阴影
struct AppShadow {
    static let card = Color.neonBlue.opacity(0.15)
    static let button = Color.neonBlue.opacity(0.3)
}

// MARK: - 视图扩展
extension View {
    func cardStyle() -> some View {
        self
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.backgroundLight)
            .cornerRadius(CornerRadius.medium)
            .shadow(color: AppShadow.card, radius: 4, x: 0, y: 4)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.md)
            .background(LinearGradient.primaryGradient)
            .cornerRadius(CornerRadius.small)
            .shadow(color: AppShadow.button, radius: 2, x: 0, y: 2)
    }
}

import SwiftUI

enum AppTheme {
    static let spacing: CGFloat = 12
    static let compactSpacing: CGFloat = 8
    static let microSpacing: CGFloat = 2
    static let textSpacing: CGFloat = 4
    static let pagePadding: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let screenVerticalPadding: CGFloat = 12
    static let controlSize: CGFloat = 52
    static let controlHeight: CGFloat = 48
    static let levelLabelVerticalPadding: CGFloat = 9
    static let answerHeight: CGFloat = 70
    static let answerHorizontalPadding: CGFloat = 22
    static let caretWidth: CGFloat = 2
    static let caretHeight: CGFloat = 34
    static let tabBarHeight: CGFloat = 62
    static let tabBarMaxWidth: CGFloat = 360
    static let tabBarPadding: CGFloat = 5
    static let tabBarBottomPadding: CGFloat = 8
    static let tabIconSize: CGFloat = 18
    static let separatorHeight: CGFloat = 1
    static let statTileMinHeight: CGFloat = 76
    static let levelTileMinHeight: CGFloat = 68
    static let emptyStateMinHeight: CGFloat = 160
    static let minimumKeyHeight: CGFloat = 74
    static let maxContentWidth: CGFloat = 620
    static let cornerRadius: CGFloat = 18
    static let compactCornerRadius: CGFloat = 12
    static let minimumTapSize: CGFloat = 44

    static let background = Color(red: 0.035, green: 0.038, blue: 0.044)
    static let surface = Color(red: 0.105, green: 0.11, blue: 0.125)
    static let raisedSurface = Color(red: 0.135, green: 0.14, blue: 0.158)
    static let controlSurface = Color(red: 0.15, green: 0.155, blue: 0.172)
    static let keySurface = Color(red: 0.18, green: 0.19, blue: 0.21)
    static let keySurfaceActive = Color(red: 0.205, green: 0.215, blue: 0.23)
    static let border = Color.white.opacity(0.12)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.64)
    static let accent = Color.white.opacity(0.86)
    static let success = Color(red: 0.62, green: 0.74, blue: 0.66)
    static let warning = Color(red: 0.82, green: 0.68, blue: 0.48)
    static let destructive = Color(red: 0.84, green: 0.38, blue: 0.38)

    static let glassTint = Color.white.opacity(0.035)
    static let glassBase = Color.white.opacity(0.035)
    static let glassBaseStrong = Color.white.opacity(0.06)
    static let glassKeyBase = Color.white.opacity(0.105)
    static let glassSelection = Color.white.opacity(0.145)
    static let glassBorder = Color.white.opacity(0.13)
    static let glassShadow = Color.black.opacity(0.26)
}

private struct AppGlassSurfaceModifier<S: Shape>: ViewModifier {
    let shape: S
    let tint: Color?
    let base: Color
    let interactive: Bool
    let shadow: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background(base, in: shape)
                .glassEffect(Glass.regular.tint(tint).interactive(interactive), in: shape)
                .appGlassOverlays(shape: shape, shadow: shadow)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .background(base, in: shape)
                .appGlassOverlays(shape: shape, shadow: shadow)
        }
    }
}

private struct AppGlassOverlaysModifier<S: Shape>: ViewModifier {
    let shape: S
    let shadow: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                shape
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.16),
                                Color.white.opacity(0.035),
                                Color.black.opacity(0.08),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            }
            .overlay {
                shape
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.34),
                                AppTheme.glassBorder,
                                Color.black.opacity(0.18),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)
            }
            .shadow(color: shadow ? AppTheme.glassShadow : .clear, radius: shadow ? 18 : 0, y: shadow ? 10 : 0)
    }
}

extension View {
    func appGlassSurface<S: Shape>(
        in shape: S,
        tint: Color? = AppTheme.glassTint,
        base: Color = AppTheme.glassBase,
        interactive: Bool = false,
        shadow: Bool = true
    ) -> some View {
        modifier(
            AppGlassSurfaceModifier(
                shape: shape,
                tint: tint,
                base: base,
                interactive: interactive,
                shadow: shadow
            )
        )
    }

    fileprivate func appGlassOverlays<S: Shape>(shape: S, shadow: Bool) -> some View {
        modifier(AppGlassOverlaysModifier(shape: shape, shadow: shadow))
    }
}

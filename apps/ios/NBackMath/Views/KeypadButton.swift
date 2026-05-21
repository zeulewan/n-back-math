import SwiftUI

struct KeypadButton: View {
    var title: String? = nil
    var systemImage: String? = nil
    let height: CGFloat
    var isProminent = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let title {
                    Text(title)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .monospacedDigit()
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 28, weight: .bold))
                }
            }
            .foregroundStyle(isProminent ? AppTheme.primaryText : AppTheme.secondaryText)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(
                LinearGradient(
                    colors: [
                        isProminent ? AppTheme.keySurfaceActive : AppTheme.controlSurface,
                        AppTheme.keySurface,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(Color.white.opacity(isProminent ? 0.12 : 0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .scaleEffect(1)
    }
}

#Preview {
    KeypadButton(title: "7", height: 96, action: {})
        .padding()
        .background(AppTheme.background)
}

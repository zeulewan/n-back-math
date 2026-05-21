import SwiftUI

struct StatsGridView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: AppTheme.textSpacing) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
                .textCase(.uppercase)

            Text(value)
                .font(.title3.bold())
                .monospacedDigit()
                .foregroundStyle(AppTheme.primaryText)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: AppTheme.statTileMinHeight)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.compactCornerRadius))
    }
}

#Preview {
    StatsGridView(title: "Accuracy", value: "92%")
        .padding()
        .background(AppTheme.background)
}

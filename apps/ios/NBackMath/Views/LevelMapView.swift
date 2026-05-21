import SwiftUI

struct LevelMapView: View {
    @ObservedObject var model: GameViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppTheme.compactSpacing), count: 4)

    var body: some View {
        let levelShape = RoundedRectangle(cornerRadius: AppTheme.compactCornerRadius)

        VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
            Text("Level Map")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)

            LazyVGrid(columns: columns, spacing: AppTheme.compactSpacing) {
                ForEach(model.levelRecords()) { record in
                    Button(action: { model.chooseLevel(record) }) {
                        VStack(spacing: AppTheme.textSpacing) {
                            Text(record.level.shortLabel)
                                .font(.subheadline.bold())

                            Text("\(record.bestAccuracy)%")
                                .font(.caption.monospacedDigit())

                            Text("\(record.runs) runs")
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, minHeight: AppTheme.levelTileMinHeight)
                        .background(record.isComplete ? AppTheme.controlSurface : AppTheme.surface, in: levelShape)
                        .overlay {
                            levelShape
                                .stroke(Color.white.opacity(record.isComplete ? 0.18 : 0.1), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(record.isComplete ? AppTheme.primaryText : AppTheme.secondaryText)
                    .disabled(model.canAdjustLevel == false)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.raisedSurface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}

#Preview {
    LevelMapView(model: GameViewModel())
        .padding()
        .background(AppTheme.background)
}

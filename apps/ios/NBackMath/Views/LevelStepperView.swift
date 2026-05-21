import SwiftUI

struct LevelStepperView: View {
    @ObservedObject var model: GameViewModel

    var body: some View {
        let controlShape = RoundedRectangle(cornerRadius: AppTheme.compactCornerRadius)

        HStack(spacing: AppTheme.compactSpacing) {
            Button("Decrease level", systemImage: "minus", action: decreaseLevel)
                .labelStyle(.iconOnly)
                .font(.system(size: 21, weight: .bold))
                .frame(width: AppTheme.controlSize, height: AppTheme.controlHeight)
                .background(AppTheme.controlSurface, in: controlShape)
                .overlay {
                    controlShape
                        .stroke(AppTheme.border)
                }
                .foregroundStyle(model.levelIndex == 0 ? AppTheme.secondaryText.opacity(0.55) : AppTheme.primaryText)
                .opacity(model.canAdjustLevel ? 1 : 0.82)

            VStack(spacing: AppTheme.textSpacing) {
                Text("Level")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .textCase(.uppercase)

                Text(model.level.label)
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.primaryText)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.levelLabelVerticalPadding)
            .background(AppTheme.controlSurface, in: controlShape)
            .overlay {
                controlShape
                    .stroke(AppTheme.border)
            }

            Button("Increase level", systemImage: "plus", action: increaseLevel)
                .labelStyle(.iconOnly)
                .font(.system(size: 21, weight: .bold))
                .frame(width: AppTheme.controlSize, height: AppTheme.controlHeight)
                .background(AppTheme.controlSurface, in: controlShape)
                .overlay {
                    controlShape
                        .stroke(AppTheme.border)
                }
                .foregroundStyle(model.levelIndex == GameLevel.all.count - 1 ? AppTheme.secondaryText.opacity(0.55) : AppTheme.primaryText)
                .opacity(model.canAdjustLevel ? 1 : 0.82)

            Button(model.primaryButtonTitle, systemImage: model.primaryButtonSystemImage, action: model.primaryAction)
                .labelStyle(.iconOnly)
                .font(.system(size: 17, weight: .bold))
                .frame(width: AppTheme.controlSize, height: AppTheme.controlHeight)
                .background(AppTheme.controlSurface, in: controlShape)
                .overlay {
                    controlShape
                        .stroke(AppTheme.border)
                }
                .foregroundStyle(AppTheme.primaryText)
        }
        .buttonStyle(.plain)
    }

    private func decreaseLevel() {
        guard model.levelIndex > 0 else {
            return
        }

        model.adjustLevel(by: -1)
    }

    private func increaseLevel() {
        guard model.levelIndex < GameLevel.all.count - 1 else {
            return
        }

        model.adjustLevel(by: 1)
    }
}

#Preview {
    LevelStepperView(model: GameViewModel())
        .padding()
        .background(AppTheme.background)
}

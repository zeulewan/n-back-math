import SwiftUI

struct ProblemScreenView: View {
    @ObservedObject var model: GameViewModel

    var body: some View {
        VStack(spacing: AppTheme.compactSpacing) {
            HStack {
                Text(model.phase.label)
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.secondaryText)
                    .textCase(.uppercase)

                Spacer()

                Text("\(model.round) / \(GameViewModel.totalRounds)")
                    .font(.caption.monospacedDigit().bold())
                    .foregroundStyle(AppTheme.secondaryText)

                Spacer()

                Text(model.lastOutcome?.label ?? " ")
                    .font(.caption.bold())
                    .foregroundStyle(model.lastOutcome == .correct ? AppTheme.success : AppTheme.destructive)
                    .textCase(.uppercase)
            }

            if model.isGameActive {
                ProgressView(value: model.timerProgress)
                    .tint(AppTheme.accent)
                    .opacity(0.92)
                    .transition(.opacity)
            }

            Text(displayText)
                .font(.system(size: model.phase == .idle ? 30 : 46, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundStyle(model.phase == .idle ? AppTheme.secondaryText : AppTheme.primaryText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentTransition(.numericText())
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.raisedSurface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.border)
        }
    }

    private var displayText: String {
        model.phase == .idle ? "Tap Play to start" : model.problemText
    }
}

#Preview {
    ProblemScreenView(model: GameViewModel())
        .padding()
        .background(AppTheme.background)
}

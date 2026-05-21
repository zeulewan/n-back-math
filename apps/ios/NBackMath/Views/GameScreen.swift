import SwiftUI

struct GameScreen: View {
    @ObservedObject var model: GameViewModel

    var body: some View {
        GeometryReader { proxy in
            let topHeight = min(max(proxy.size.height * 0.27, 205), 275)
            let columnWidth = min(max(proxy.size.width - (AppTheme.pagePadding * 2), 0), AppTheme.maxContentWidth)

            VStack(spacing: AppTheme.spacing) {
                VStack(spacing: AppTheme.compactSpacing) {
                    LevelStepperView(model: model)
                    ProblemScreenView(model: model)
                }
                .frame(height: topHeight)
                .frame(width: columnWidth)

                VStack(spacing: AppTheme.compactSpacing) {
                    if model.phase == .finished {
                        FinishSummaryView(model: model)
                    }
                    AnswerPadView(model: model)
                }
                .frame(maxHeight: .infinity)
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, AppTheme.screenVerticalPadding)
            .padding(.bottom, AppTheme.screenVerticalPadding)
            .background {
                ZStack {
                    LinearGradient(
                        colors: [
                            AppTheme.background,
                            Color(red: 0.045, green: 0.048, blue: 0.056),
                            Color(red: 0.025, green: 0.027, blue: 0.032),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.075),
                            Color.clear,
                            Color.white.opacity(0.035),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blendMode(.screen)
                }
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    GameScreen(model: GameViewModel())
}

import SwiftUI

struct StatsScreen: View {
    @ObservedObject var model: GameViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacing) {
                    Text("Progress")
                        .font(.largeTitle.bold())
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: AppTheme.compactSpacing) {
                        StatsGridView(title: "Runs", value: String(model.progress.runs.count))
                        StatsGridView(title: "Accuracy", value: "\(model.lifetimeAccuracy)%")
                    }

                    HStack(spacing: AppTheme.compactSpacing) {
                        StatsGridView(title: "Best Run", value: "\(model.bestAccuracy)%")
                        StatsGridView(title: "Best Streak", value: String(model.bestStreak))
                    }

                    LevelMapView(model: model)
                    HistoryListView(records: Array(model.progress.runs.prefix(8)))

                    Button("Clear Progress", role: .destructive, action: model.clearProgress)
                        .buttonStyle(.bordered)
                        .disabled(model.isGameActive)
                }
                .padding(AppTheme.pagePadding)
            }
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
                            Color.white.opacity(0.07),
                            Color.clear,
                            Color.white.opacity(0.03),
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
    StatsScreen(model: GameViewModel())
}

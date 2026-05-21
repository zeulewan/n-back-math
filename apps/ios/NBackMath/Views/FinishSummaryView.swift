import SwiftUI

struct FinishSummaryView: View {
    @ObservedObject var model: GameViewModel

    var body: some View {
        HStack(spacing: AppTheme.compactSpacing) {
            StatsGridView(title: "Correct", value: String(model.correct))
            StatsGridView(title: "Missed", value: String(model.missed))
            StatsGridView(title: "Accuracy", value: "\(model.correct * 100 / GameViewModel.totalRounds)%")
        }
        .transition(.opacity.combined(with: .scale))
    }
}

#Preview {
    FinishSummaryView(model: GameViewModel())
        .padding()
        .background(AppTheme.background)
}

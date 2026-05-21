import SwiftUI

struct HistoryListView: View {
    let records: [RunRecord]

    var body: some View {
        let rowShape = RoundedRectangle(cornerRadius: AppTheme.compactCornerRadius)

        VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
            Text("Recent Runs")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)

            if records.isEmpty {
                ContentUnavailableView("No saved runs", systemImage: "clock", description: Text("Completed rounds will appear here."))
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: AppTheme.emptyStateMinHeight)
            } else {
                ForEach(records) { record in
                    HStack {
                        VStack(alignment: .leading, spacing: AppTheme.microSpacing) {
                            Text(record.levelLabel)
                                .font(.subheadline.bold())
                                .foregroundStyle(AppTheme.primaryText)

                            Text(record.completedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: AppTheme.microSpacing) {
                            Text("\(record.accuracy)%")
                                .font(.headline.monospacedDigit())
                                .foregroundStyle(AppTheme.primaryText)

                            Text("\(record.correct)/\(record.rounds)")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                    .padding(AppTheme.cardPadding)
                    .background(AppTheme.surface, in: rowShape)
                    .overlay {
                        rowShape
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    }
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.raisedSurface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}

#Preview {
    HistoryListView(records: [])
        .padding()
        .background(AppTheme.background)
}

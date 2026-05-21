import SwiftUI

struct AnswerPadView: View {
    @ObservedObject var model: GameViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppTheme.spacing), count: 3)

    var body: some View {
        GeometryReader { proxy in
            let padWidth = min(proxy.size.width, AppTheme.maxContentWidth)
            let availableKeyHeight = proxy.size.height - AppTheme.answerHeight - (AppTheme.spacing * 4)
            let keyHeight = max(availableKeyHeight / 4, AppTheme.minimumKeyHeight)

            VStack(spacing: AppTheme.spacing) {
                answerField
                    .frame(maxWidth: .infinity, minHeight: AppTheme.answerHeight, alignment: .trailing)

                LazyVGrid(columns: columns, spacing: AppTheme.spacing) {
                    ForEach(1...9, id: \.self) { digit in
                        KeypadButton(title: String(digit), height: keyHeight) {
                            model.appendDigit(digit)
                        }
                    }

                    Color.clear
                        .frame(height: keyHeight)

                    KeypadButton(title: "0", height: keyHeight) {
                        model.appendDigit(0)
                    }

                    KeypadButton(systemImage: "delete.left", height: keyHeight, isProminent: model.canClearAnswer) {
                        model.clearAnswer()
                    }
                }
            }
            .frame(width: padWidth)
            .frame(maxHeight: .infinity, alignment: .top)
            .frame(maxWidth: .infinity)
        }
    }

    private var answerField: some View {
        HStack(spacing: AppTheme.compactSpacing) {
            Spacer(minLength: 0)

            if model.answerText.isEmpty {
                Text(model.acceptingAnswer ? "Enter answer" : " ")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText.opacity(0.52))
            } else {
                Text(model.answerText)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.primaryText)
            }

            if model.acceptingAnswer {
                RoundedRectangle(cornerRadius: AppTheme.caretWidth / 2)
                    .fill(AppTheme.accent)
                    .frame(width: AppTheme.caretWidth, height: AppTheme.caretHeight)
            }
        }
        .padding(.horizontal, AppTheme.answerHorizontalPadding)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.border)
        }
    }
}

#Preview {
    AnswerPadView(model: GameViewModel())
        .padding()
        .background(AppTheme.background)
}

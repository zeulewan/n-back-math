import SwiftUI

struct RootView: View {
    enum Tab: Hashable {
        case play
        case stats
    }

    @StateObject private var model = GameViewModel()
    @State private var selectedTab: Tab

    init() {
        let initialTab: Tab = ProcessInfo.processInfo.arguments.contains("--screenshot-tab=stats") ? .stats : .play
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        ZStack {
            switch selectedTab {
            case .play:
                GameScreen(model: model)
                    .transition(.opacity)
            case .stats:
                StatsScreen(model: model)
                    .transition(.opacity)
            }
        }
        .animation(.snappy(duration: 0.18), value: selectedTab)
        .tint(AppTheme.accent)
        .safeAreaInset(edge: .bottom, spacing: .zero) {
            bottomTabBar
        }
        .onChange(of: model.isGameActive) { _, isActive in
            if isActive {
                selectedTab = .play
            }
        }
    }

    private var bottomTabBar: some View {
        let tabBarShape = Capsule()

        return HStack(spacing: .zero) {
            tabButton("Play", systemImage: "number.square", tab: .play)
            tabButton("Stats", systemImage: "chart.bar.xaxis", tab: .stats)
        }
        .padding(AppTheme.tabBarPadding)
        .frame(height: AppTheme.tabBarHeight)
        .frame(maxWidth: AppTheme.tabBarMaxWidth)
        .background {
            if #available(iOS 26.0, *) {
                tabBarShape
                    .fill(Color.black.opacity(0.12))
                    .glassEffect(Glass.regular.tint(AppTheme.glassTint).interactive(), in: tabBarShape)
            } else {
                tabBarShape
                    .fill(.ultraThinMaterial)
            }
        }
        .overlay {
            tabBarShape
                .stroke(AppTheme.glassBorder, lineWidth: AppTheme.separatorHeight)
        }
        .shadow(color: AppTheme.glassShadow, radius: 18, y: 8)
        .padding(.horizontal, AppTheme.pagePadding)
        .padding(.bottom, AppTheme.tabBarBottomPadding)
    }

    private func tabButton(_ title: String, systemImage: String, tab: Tab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            selectedTab = tab
        } label: {
            HStack(spacing: AppTheme.textSpacing) {
                Image(systemName: systemImage)
                    .font(.system(size: AppTheme.tabIconSize, weight: .semibold))

                Text(title)
                    .font(.footnote.weight(.semibold))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(isSelected ? AppTheme.primaryText : AppTheme.secondaryText)
            .background {
                if isSelected {
                    Capsule()
                        .fill(AppTheme.glassSelection)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RootView()
}

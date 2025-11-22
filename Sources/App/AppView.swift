import SwiftUI
import ComposableArchitecture
import Features
import DesignSystem

public struct AppView: View {
    @Perception.Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            Group {
                if store.isAuthenticated {
                    mainTabView
                } else {
                    AuthenticationView(
                        store: store.scope(state: \.authState, action: \.auth)
                    )
                }
            }
            .onAppear {
                store.send(.appLaunched)
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            ForEach(AppFeature.Tab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.rawValue, systemImage: tab.iconName)
                    }
                    .tag(tab)
            }
        }
    }

    @ViewBuilder
    private func tabContent(for tab: AppFeature.Tab) -> some View {
        switch tab {
        case .office:
            OfficeListView(
                store: store.scope(state: \.officeList, action: \.officeList)
            )

        case .timer:
            TimerView(
                store: store.scope(state: \.timer, action: \.timer)
            )

        case .friends:
            FriendsView(
                store: store.scope(state: \.friends, action: \.friends)
            )

        case .stats:
            StatisticsView(
                store: store.scope(state: \.statistics, action: \.statistics)
            )

        case .profile:
            PlaceholderView(title: "Profile", icon: "person.circle.fill")
        }
    }
}

// MARK: - Placeholder View

private struct PlaceholderView: View {
    let title: String
    let icon: String

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Image(systemName: icon)
                    .font(.system(size: 64))
                    .foregroundStyle(Color.labelTertiary)

                Text(title)
                    .font(.displayTitle3)
                    .foregroundStyle(Color.labelPrimary)

                Text("Coming soon...")
                    .font(.bodyRegular)
                    .foregroundStyle(Color.labelSecondary)
            }
            .navigationTitle(title)
        }
    }
}

// MARK: - Preview

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}

import Foundation
import ComposableArchitecture
import Features

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        public var authState: AuthenticationFeature.State
        public var selectedTab: Tab = .office
        public var officeList: OfficeListFeature.State
        public var timer: TimerFeature.State

        public init() {
            self.authState = AuthenticationFeature.State()
            self.officeList = OfficeListFeature.State()
            self.timer = TimerFeature.State()
        }

        public var isAuthenticated: Bool {
            authState.isAuthenticated
        }
    }

    public enum Action: Equatable {
        case auth(AuthenticationFeature.Action)
        case tabSelected(Tab)
        case officeList(OfficeListFeature.Action)
        case timer(TimerFeature.Action)
        case appLaunched
        case restoreSessionCompleted

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.tabSelected(let l), .tabSelected(let r)): return l == r
            case (.appLaunched, .appLaunched): return true
            case (.restoreSessionCompleted, .restoreSessionCompleted): return true
            case (.auth(let l), .auth(let r)): return l == r
            case (.officeList(let l), .officeList(let r)): return l == r
            case (.timer(let l), .timer(let r)): return l == r
            default: return false
            }
        }
    }

    public enum Tab: String, CaseIterable, Equatable {
        case office = "Office"
        case timer = "Timer"
        case friends = "Friends"
        case stats = "Stats"
        case profile = "Profile"

        public var iconName: String {
            switch self {
            case .office: return "building.2"
            case .timer: return "timer"
            case .friends: return "person.2"
            case .stats: return "chart.bar"
            case .profile: return "person.circle"
            }
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.authState, action: \.auth) {
            AuthenticationFeature()
        }

        Scope(state: \.officeList, action: \.officeList) {
            OfficeListFeature()
        }

        Scope(state: \.timer, action: \.timer) {
            TimerFeature()
        }

        Reduce { state, action in
            switch action {
            case .appLaunched:
                // Try to restore session
                return .send(.auth(.restoreSession))

            case .auth(.loginResponse(.success)):
                state.authState.isAuthenticated = true
                return .send(.restoreSessionCompleted)

            case .auth:
                return .none

            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none

            case .officeList:
                return .none

            case .timer:
                return .none

            case .restoreSessionCompleted:
                // Load initial data
                return .send(.officeList(.loadOffices))
            }
        }
    }
}

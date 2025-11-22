import Foundation
import ComposableArchitecture

@Reducer
public struct StatisticsFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedPeriod: StatisticsPeriod = .week
        public var statistics: PersonalStatistics?
        public var isLoading: Bool = false
        public var error: String?

        public init() {}

        // Computed properties for quick stats
        public var totalHours: Double {
            guard let stats = statistics else { return 0 }
            return stats.totalFocusTime / 3600
        }

        public var todayPomodoros: Int {
            guard let stats = statistics,
                  let today = stats.dailyStats.first else { return 0 }
            return today.completedPomodoros
        }
    }

    public enum Action: Equatable {
        case loadStatistics
        case periodChanged(StatisticsPeriod)
        case statisticsLoaded(Result<PersonalStatistics, Error>)
        case refreshStatistics

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.loadStatistics, .loadStatistics): return true
            case (.refreshStatistics, .refreshStatistics): return true
            case (.periodChanged(let l), .periodChanged(let r)): return l == r
            case (.statisticsLoaded(.success(let l)), .statisticsLoaded(.success(let r))): return l == r
            case (.statisticsLoaded(.failure), .statisticsLoaded(.failure)): return true
            default: return false
            }
        }
    }

    @Dependency(\.networkService) var networkService

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadStatistics, .refreshStatistics:
                state.isLoading = true
                state.error = nil

                return .run { send in
                    await send(.statisticsLoaded(
                        Result {
                            let endpoint = Endpoint.getPersonalStats()
                            return try await networkService.request(
                                endpoint,
                                type: PersonalStatistics.self
                            )
                        }
                    ))
                }

            case .periodChanged(let period):
                state.selectedPeriod = period
                return .send(.loadStatistics)

            case .statisticsLoaded(.success(let statistics)):
                state.isLoading = false
                state.statistics = statistics
                return .none

            case .statisticsLoaded(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
            }
        }
    }
}

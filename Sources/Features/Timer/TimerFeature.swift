import Foundation
import ComposableArchitecture

@Reducer
public struct TimerFeature {
    @ObservableState
    public struct State: Equatable {
        public var timeRemaining: TimeInterval
        public var totalDuration: TimeInterval
        public var isRunning: Bool = false
        public var isPaused: Bool = false
        public var currentPhase: SessionPhase = .work
        public var completedPomodoros: Int = 0
        public var completedPomodorosToday: Int = 0
        public var settings: TimerSettings = .default
        public var currentSessionId: UUID?

        public init(
            timeRemaining: TimeInterval? = nil,
            totalDuration: TimeInterval? = nil,
            currentPhase: SessionPhase = .work,
            settings: TimerSettings = .default
        ) {
            self.currentPhase = currentPhase
            self.settings = settings
            self.totalDuration = totalDuration ?? currentPhase.defaultDuration
            self.timeRemaining = timeRemaining ?? self.totalDuration
        }

        public var progress: Double {
            guard totalDuration > 0 else { return 0 }
            return 1 - (timeRemaining / totalDuration)
        }

        public var formattedTime: String {
            let minutes = Int(timeRemaining) / 60
            let seconds = Int(timeRemaining) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }

        public var nextPhase: SessionPhase {
            switch currentPhase {
            case .work:
                return (completedPomodoros + 1) % settings.sessionsUntilLongBreak == 0
                    ? .longBreak
                    : .shortBreak
            case .shortBreak, .longBreak:
                return .work
            }
        }
    }

    public enum Action: Equatable {
        case startTimer
        case pauseTimer
        case resumeTimer
        case stopTimer
        case timerTicked
        case completeSession
        case skipToBreak
        case skipToWork
        case updateSettings(TimerSettings)
        case sessionCreated(Result<UUID, Error>)
        case sessionUpdated
        case notificationScheduled

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.startTimer, .startTimer): return true
            case (.pauseTimer, .pauseTimer): return true
            case (.resumeTimer, .resumeTimer): return true
            case (.stopTimer, .stopTimer): return true
            case (.timerTicked, .timerTicked): return true
            case (.completeSession, .completeSession): return true
            case (.skipToBreak, .skipToBreak): return true
            case (.skipToWork, .skipToWork): return true
            case (.updateSettings(let l), .updateSettings(let r)): return l == r
            case (.sessionCreated(.success(let l)), .sessionCreated(.success(let r))): return l == r
            case (.sessionCreated(.failure), .sessionCreated(.failure)): return true
            case (.sessionUpdated, .sessionUpdated): return true
            case (.notificationScheduled, .notificationScheduled): return true
            default: return false
            }
        }
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.networkService) var networkService
    @Dependency(\.webSocketManager) var webSocketManager
    @Dependency(\.liveActivityManager) var liveActivityManager

    private enum CancelID { case timer }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startTimer:
                state.isRunning = true
                state.isPaused = false
                state.timeRemaining = state.totalDuration

                // Start Live Activity
                let liveActivityEffect: Effect<Action> = .run {
                    [phase = state.currentPhase,
                     timeRemaining = state.timeRemaining,
                     totalDuration = state.totalDuration,
                     completedPomodoros = state.completedPomodorosToday] _ in
                    if #available(iOS 16.1, *) {
                        try? await liveActivityManager.startActivity(
                            phase: phase.rawValue,
                            timeRemaining: timeRemaining,
                            totalDuration: totalDuration,
                            completedPomodoros: completedPomodoros,
                            officeName: nil
                        )
                    }
                }

                // Create session on backend
                return .merge(
                    liveActivityEffect,
                    .run { [phase = state.currentPhase, duration = state.totalDuration] send in
                        await send(.sessionCreated(
                            Result {
                                let endpoint = Endpoint.createSession(
                                    phase: phase,
                                    duration: duration,
                                    officeId: nil
                                )
                                let response: SessionResponse = try await networkService.request(
                                    endpoint,
                                    type: SessionResponse.self
                                )
                                return response.id
                            }
                        ))
                    },
                    .run { send in
                        for await _ in clock.timer(interval: .seconds(1)) {
                            await send(.timerTicked)
                        }
                    }
                    .cancellable(id: CancelID.timer, cancelInFlight: true)
                )

            case .pauseTimer:
                state.isPaused = true

                // Update Live Activity
                let updateEffect: Effect<Action> = .run { [timeRemaining = state.timeRemaining] _ in
                    if #available(iOS 16.1, *) {
                        try? await liveActivityManager.updateActivity(
                            timeRemaining: timeRemaining,
                            isRunning: false
                        )
                    }
                }

                return .merge(
                    updateEffect,
                    .cancel(id: CancelID.timer)
                )

            case .resumeTimer:
                state.isPaused = false

                // Update Live Activity
                let updateEffect: Effect<Action> = .run { [timeRemaining = state.timeRemaining] _ in
                    if #available(iOS 16.1, *) {
                        try? await liveActivityManager.updateActivity(
                            timeRemaining: timeRemaining,
                            isRunning: true
                        )
                    }
                }

                return .merge(
                    updateEffect,
                    .run { send in
                        for await _ in clock.timer(interval: .seconds(1)) {
                            await send(.timerTicked)
                        }
                    }
                    .cancellable(id: CancelID.timer, cancelInFlight: true)
                )

            case .stopTimer:
                state.isRunning = false
                state.isPaused = false
                state.timeRemaining = state.totalDuration
                state.currentSessionId = nil

                // End Live Activity
                let endActivityEffect: Effect<Action> = .run { _ in
                    if #available(iOS 16.1, *) {
                        await liveActivityManager.endActivity()
                    }
                }

                return .merge(
                    endActivityEffect,
                    .cancel(id: CancelID.timer)
                )

            case .timerTicked:
                guard state.timeRemaining > 0 else {
                    return .send(.completeSession)
                }

                state.timeRemaining -= 1

                // Update Live Activity every second
                let liveActivityEffect: Effect<Action> = .run { [timeRemaining = state.timeRemaining] _ in
                    if #available(iOS 16.1, *) {
                        try? await liveActivityManager.updateActivity(
                            timeRemaining: timeRemaining,
                            isRunning: true
                        )
                    }
                }

                // Send WebSocket update every 10 seconds
                if Int(state.timeRemaining) % 10 == 0, let sessionId = state.currentSessionId {
                    return .merge(
                        liveActivityEffect,
                        .run { [timeRemaining = state.timeRemaining] _ in
                            try? await webSocketManager.send(
                                .timerUpdate(
                                    TimerUpdateMessage(
                                        sessionId: sessionId,
                                        timeRemaining: timeRemaining
                                    )
                                )
                            )
                        }
                    )
                }

                return liveActivityEffect

            case .completeSession:
                state.isRunning = false
                state.isPaused = false

                if state.currentPhase == .work {
                    state.completedPomodoros += 1
                    state.completedPomodorosToday += 1
                }

                let nextPhase = state.nextPhase
                state.currentPhase = nextPhase
                state.totalDuration = nextPhase.defaultDuration
                state.timeRemaining = state.totalDuration

                // Update Live Activity with new phase
                let updatePhaseEffect: Effect<Action> = .run {
                    [phase = state.currentPhase,
                     timeRemaining = state.timeRemaining,
                     totalDuration = state.totalDuration,
                     completedPomodoros = state.completedPomodorosToday] _ in
                    if #available(iOS 16.1, *) {
                        try? await liveActivityManager.updatePhase(
                            phase: phase.rawValue,
                            timeRemaining: timeRemaining,
                            totalDuration: totalDuration,
                            completedPomodoros: completedPomodoros
                        )
                    }
                }

                // Send completion to backend
                return .merge(
                    updatePhaseEffect,
                    .run { [sessionId = state.currentSessionId] send in
                        if let sessionId = sessionId {
                            try? await webSocketManager.send(
                                .timerComplete(TimerCompleteMessage(sessionId: sessionId))
                            )

                            let endpoint = Endpoint.updateSession(
                                id: sessionId,
                                updates: ["completed": true]
                            )
                            try? await networkService.request(endpoint)
                        }
                        await send(.sessionUpdated)
                    },
                    .run { _ in
                        // TODO: Schedule notification, haptic feedback
                    }
                )

            case .skipToBreak:
                state.isRunning = false
                state.isPaused = false
                state.currentPhase = state.nextPhase
                state.totalDuration = state.currentPhase.defaultDuration
                state.timeRemaining = state.totalDuration
                return .cancel(id: CancelID.timer)

            case .skipToWork:
                state.isRunning = false
                state.isPaused = false
                state.currentPhase = .work
                state.totalDuration = state.settings.workDuration
                state.timeRemaining = state.totalDuration
                return .cancel(id: CancelID.timer)

            case .updateSettings(let settings):
                state.settings = settings
                // Update durations if not running
                if !state.isRunning {
                    switch state.currentPhase {
                    case .work:
                        state.totalDuration = settings.workDuration
                    case .shortBreak:
                        state.totalDuration = settings.shortBreakDuration
                    case .longBreak:
                        state.totalDuration = settings.longBreakDuration
                    }
                    state.timeRemaining = state.totalDuration
                }
                return .none

            case .sessionCreated(.success(let sessionId)):
                state.currentSessionId = sessionId

                // Send WebSocket message
                return .run { [sessionId, phase = state.currentPhase, duration = state.totalDuration] _ in
                    try? await webSocketManager.send(
                        .timerStart(
                            TimerStartMessage(
                                sessionId: sessionId,
                                duration: duration,
                                phase: phase
                            )
                        )
                    )
                }

            case .sessionCreated(.failure):
                // Continue timer even if backend fails
                return .none

            case .sessionUpdated:
                state.currentSessionId = nil
                return .none

            case .notificationScheduled:
                return .none
            }
        }
    }
}

// MARK: - Session Response

struct SessionResponse: Codable {
    let id: UUID
    let userId: UUID
    let phase: SessionPhase
    let startTime: Date
    let plannedDuration: TimeInterval
}

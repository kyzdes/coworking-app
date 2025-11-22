import ActivityKit
import Foundation
import Dependencies

/// Manager for Live Activities
@available(iOS 16.1, *)
public actor LiveActivityManager {
    private var currentActivity: Activity<PomodoroTimerAttributes>?

    public init() {}

    // MARK: - Public Methods

    /// Start a new Live Activity for a Pomodoro session
    public func startActivity(
        phase: String,
        timeRemaining: TimeInterval,
        totalDuration: TimeInterval,
        completedPomodoros: Int,
        officeName: String? = nil
    ) async throws {
        // End existing activity if any
        await endActivity()

        let attributes = PomodoroTimerAttributes(
            officeName: officeName,
            startTime: Date()
        )

        let contentState = PomodoroTimerAttributes.ContentState(
            timeRemaining: timeRemaining,
            phase: phase,
            isRunning: true,
            totalDuration: totalDuration,
            completedPomodoros: completedPomodoros
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil)
            )
            currentActivity = activity
        } catch {
            throw LiveActivityError.failedToStart(error)
        }
    }

    /// Update the current Live Activity
    public func updateActivity(
        timeRemaining: TimeInterval,
        isRunning: Bool,
        completedPomodoros: Int? = nil
    ) async throws {
        guard let activity = currentActivity else {
            throw LiveActivityError.noActiveActivity
        }

        var newState = activity.content.state
        newState.timeRemaining = timeRemaining
        newState.isRunning = isRunning

        if let completedPomodoros = completedPomodoros {
            newState.completedPomodoros = completedPomodoros
        }

        await activity.update(
            .init(state: newState, staleDate: nil)
        )
    }

    /// Update phase (when transitioning from work to break, etc.)
    public func updatePhase(
        phase: String,
        timeRemaining: TimeInterval,
        totalDuration: TimeInterval,
        completedPomodoros: Int
    ) async throws {
        guard let activity = currentActivity else {
            throw LiveActivityError.noActiveActivity
        }

        let newState = PomodoroTimerAttributes.ContentState(
            timeRemaining: timeRemaining,
            phase: phase,
            isRunning: true,
            totalDuration: totalDuration,
            completedPomodoros: completedPomodoros
        )

        await activity.update(
            .init(state: newState, staleDate: nil)
        )
    }

    /// End the current Live Activity
    public func endActivity() async {
        guard let activity = currentActivity else { return }

        await activity.end(
            .init(state: activity.content.state, staleDate: nil),
            dismissalPolicy: .default
        )

        currentActivity = nil
    }

    /// Check if there's an active Live Activity
    public var hasActiveActivity: Bool {
        currentActivity != nil
    }
}

// MARK: - Errors

public enum LiveActivityError: LocalizedError {
    case failedToStart(Error)
    case noActiveActivity
    case updateFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .failedToStart(let error):
            return "Failed to start Live Activity: \(error.localizedDescription)"
        case .noActiveActivity:
            return "No active Live Activity"
        case .updateFailed(let error):
            return "Failed to update Live Activity: \(error.localizedDescription)"
        }
    }
}

// MARK: - Dependency

@available(iOS 16.1, *)
extension LiveActivityManager: DependencyKey {
    public static let liveValue = LiveActivityManager()
    public static let testValue = LiveActivityManager()
}

extension DependencyValues {
    public var liveActivityManager: LiveActivityManager {
        get {
            if #available(iOS 16.1, *) {
                return self[LiveActivityManager.self]
            } else {
                fatalError("Live Activities require iOS 16.1+")
            }
        }
        set {
            if #available(iOS 16.1, *) {
                self[LiveActivityManager.self] = newValue
            }
        }
    }
}

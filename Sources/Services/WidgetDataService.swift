import Foundation
import WidgetKit
import Dependencies

/// Service for sharing data with widgets via App Group
public actor WidgetDataService {
    private let appGroupIdentifier = "group.com.virtualoffice.pomodoro"
    private let userDefaults: UserDefaults?

    public init() {
        self.userDefaults = UserDefaults(suiteName: appGroupIdentifier)
    }

    // MARK: - Public Methods

    /// Update widget with current timer state
    public func updateTimerState(
        timeRemaining: TimeInterval?,
        currentPhase: String?,
        isRunning: Bool,
        completedPomodoros: Int,
        officeName: String?
    ) {
        guard let userDefaults = userDefaults else { return }

        if let timeRemaining = timeRemaining {
            userDefaults.set(timeRemaining, forKey: "widget.timeRemaining")
        } else {
            userDefaults.removeObject(forKey: "widget.timeRemaining")
        }

        if let currentPhase = currentPhase {
            userDefaults.set(currentPhase, forKey: "widget.currentPhase")
        } else {
            userDefaults.removeObject(forKey: "widget.currentPhase")
        }

        userDefaults.set(isRunning, forKey: "widget.isRunning")
        userDefaults.set(completedPomodoros, forKey: "widget.completedPomodoros")

        if let officeName = officeName {
            userDefaults.set(officeName, forKey: "widget.officeName")
        } else {
            userDefaults.removeObject(forKey: "widget.officeName")
        }

        // Force widget reload
        reloadWidgets()
    }

    /// Clear widget data
    public func clearWidgetData() {
        guard let userDefaults = userDefaults else { return }

        userDefaults.removeObject(forKey: "widget.timeRemaining")
        userDefaults.removeObject(forKey: "widget.currentPhase")
        userDefaults.set(false, forKey: "widget.isRunning")
        userDefaults.set(0, forKey: "widget.completedPomodoros")
        userDefaults.removeObject(forKey: "widget.officeName")

        reloadWidgets()
    }

    // MARK: - Private Methods

    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Dependency

extension WidgetDataService: DependencyKey {
    public static let liveValue = WidgetDataService()
    public static let testValue = WidgetDataService()
}

extension DependencyValues {
    public var widgetDataService: WidgetDataService {
        get { self[WidgetDataService.self] }
        set { self[WidgetDataService.self] = newValue }
    }
}

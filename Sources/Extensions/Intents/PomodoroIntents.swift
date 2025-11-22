import AppIntents
import Foundation

// MARK: - Start Pomodoro Intent

@available(iOS 16.0, *)
struct StartPomodoroIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Pomodoro"
    static var description = IntentDescription("Start a new Pomodoro focus session")

    static var openAppWhenRun: Bool = true

    @Parameter(title: "Duration (minutes)", default: 25)
    var duration: Int

    @Parameter(title: "Session Type", default: .work)
    var sessionType: SessionTypeEnum

    func perform() async throws -> some IntentResult {
        // Open app with deep link to start timer
        // The app will handle this URL and start the timer
        let minutes = max(1, min(duration, 60)) // Clamp between 1-60 minutes

        // Store intent data for app to read
        UserDefaults.standard.set(minutes, forKey: "siri.timer.duration")
        UserDefaults.standard.set(sessionType.rawValue, forKey: "siri.timer.type")
        UserDefaults.standard.set(Date(), forKey: "siri.timer.requestTime")

        return .result(dialog: "Starting \(minutes) minute \(sessionType.displayName)")
    }
}

// MARK: - Stop Pomodoro Intent

@available(iOS 16.0, *)
struct StopPomodoroIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Pomodoro"
    static var description = IntentDescription("Stop the current Pomodoro session")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        // Signal app to stop timer
        UserDefaults.standard.set(true, forKey: "siri.timer.stop")
        UserDefaults.standard.set(Date(), forKey: "siri.timer.stopTime")

        return .result(dialog: "Pomodoro session stopped")
    }
}

// MARK: - Check Progress Intent

@available(iOS 16.0, *)
struct CheckProgressIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Pomodoro Progress"
    static var description = IntentDescription("Check your Pomodoro progress for today")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ReturnsValue<Int> {
        // Get today's completed pomodoros from UserDefaults
        let completedPomodoros = UserDefaults.standard.integer(forKey: "widget.completedPomodoros")

        let message = completedPomodoros == 0
            ? "You haven't completed any Pomodoros today. Start one now!"
            : "You've completed \(completedPomodoros) Pomodoro\(completedPomodoros == 1 ? "" : "s") today. Keep going!"

        return .result(value: completedPomodoros, dialog: IntentDialog(stringLiteral: message))
    }
}

// MARK: - Session Type Enum

@available(iOS 16.0, *)
enum SessionTypeEnum: String, AppEnum {
    case work
    case shortBreak
    case longBreak

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Session Type")

    static var caseDisplayRepresentations: [SessionTypeEnum: DisplayRepresentation] = [
        .work: "Focus Time",
        .shortBreak: "Short Break",
        .longBreak: "Long Break"
    ]

    var displayName: String {
        switch self {
        case .work: return "focus session"
        case .shortBreak: return "short break"
        case .longBreak: return "long break"
        }
    }
}

// MARK: - App Shortcuts Provider

@available(iOS 16.0, *)
struct PomodoroShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartPomodoroIntent(),
            phrases: [
                "Start a Pomodoro in \(.applicationName)",
                "Begin focus session in \(.applicationName)",
                "Start working in \(.applicationName)"
            ],
            shortTitle: "Start Pomodoro",
            systemImageName: "brain.head.profile"
        )

        AppShortcut(
            intent: StopPomodoroIntent(),
            phrases: [
                "Stop my Pomodoro in \(.applicationName)",
                "End focus session in \(.applicationName)",
                "Stop timer in \(.applicationName)"
            ],
            shortTitle: "Stop Pomodoro",
            systemImageName: "stop.circle"
        )

        AppShortcut(
            intent: CheckProgressIntent(),
            phrases: [
                "Check my progress in \(.applicationName)",
                "How many Pomodoros today in \(.applicationName)",
                "Show my stats in \(.applicationName)"
            ],
            shortTitle: "Check Progress",
            systemImageName: "chart.bar"
        )
    }
}

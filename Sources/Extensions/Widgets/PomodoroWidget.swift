import SwiftUI
import WidgetKit

/// Pomodoro Timer Widget Entry
struct PomodoroWidgetEntry: TimelineEntry {
    let date: Date
    let timeRemaining: TimeInterval?
    let currentPhase: String?
    let isRunning: Bool
    let completedPomodorosToday: Int
    let officeName: String?
}

/// Timeline Provider for Pomodoro Widget
struct PomodoroWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PomodoroWidgetEntry {
        PomodoroWidgetEntry(
            date: Date(),
            timeRemaining: 1500,
            currentPhase: "work",
            isRunning: false,
            completedPomodorosToday: 3,
            officeName: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PomodoroWidgetEntry) -> Void) {
        let entry = PomodoroWidgetEntry(
            date: Date(),
            timeRemaining: 1500,
            currentPhase: "work",
            isRunning: false,
            completedPomodorosToday: 3,
            officeName: nil
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PomodoroWidgetEntry>) -> Void) {
        // In real app, fetch from shared UserDefaults or App Group
        let entry = PomodoroWidgetEntry(
            date: Date(),
            timeRemaining: fetchTimeRemaining(),
            currentPhase: fetchCurrentPhase(),
            isRunning: fetchIsRunning(),
            completedPomodorosToday: fetchCompletedPomodoros(),
            officeName: fetchOfficeName()
        )

        // Update widget every minute during active session
        let updateInterval = entry.isRunning ? 60 : 3600
        let nextUpdate = Date().addingTimeInterval(TimeInterval(updateInterval))
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    // MARK: - Helper Methods

    private func fetchTimeRemaining() -> TimeInterval? {
        // TODO: Fetch from App Group UserDefaults
        return UserDefaults.standard.double(forKey: "widget.timeRemaining")
    }

    private func fetchCurrentPhase() -> String? {
        // TODO: Fetch from App Group UserDefaults
        return UserDefaults.standard.string(forKey: "widget.currentPhase")
    }

    private func fetchIsRunning() -> Bool {
        // TODO: Fetch from App Group UserDefaults
        return UserDefaults.standard.bool(forKey: "widget.isRunning")
    }

    private func fetchCompletedPomodoros() -> Int {
        // TODO: Fetch from App Group UserDefaults
        return UserDefaults.standard.integer(forKey: "widget.completedPomodoros")
    }

    private func fetchOfficeName() -> String? {
        // TODO: Fetch from App Group UserDefaults
        return UserDefaults.standard.string(forKey: "widget.officeName")
    }
}

/// Pomodoro Widget
struct PomodoroWidget: Widget {
    let kind: String = "PomodoroWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PomodoroWidgetProvider()) { entry in
            PomodoroWidgetView(entry: entry)
        }
        .configurationDisplayName("Pomodoro Timer")
        .description("Track your focus sessions at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget View

struct PomodoroWidgetView: View {
    let entry: PomodoroWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: PomodoroWidgetEntry

    var body: some View {
        ZStack {
            phaseColor
                .opacity(0.2)

            VStack(spacing: 8) {
                Image(systemName: phaseIcon)
                    .font(.system(size: 32))
                    .foregroundStyle(phaseColor)

                if let timeRemaining = entry.timeRemaining, entry.isRunning {
                    Text(formatTime(timeRemaining))
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.primary)
                } else {
                    Text("Ready")
                        .font(.headline)
                        .foregroundStyle(Color.secondary)
                }

                Text("\(entry.completedPomodorosToday)")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            .padding()
        }
    }

    private var phaseColor: Color {
        guard let phase = entry.currentPhase else {
            return Color.gray
        }

        switch phase {
        case "work": return Color(red: 0.95, green: 0.26, blue: 0.21)
        case "short_break", "long_break": return Color(red: 0.20, green: 0.78, blue: 0.35)
        default: return Color.gray
        }
    }

    private var phaseIcon: String {
        guard let phase = entry.currentPhase else {
            return "timer"
        }

        switch phase {
        case "work": return "brain.head.profile"
        case "short_break": return "cup.and.saucer.fill"
        case "long_break": return "bed.double.fill"
        default: return "timer"
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: PomodoroWidgetEntry

    var body: some View {
        ZStack {
            phaseColor
                .opacity(0.2)

            HStack(spacing: 16) {
                // Timer section
                VStack(spacing: 4) {
                    Image(systemName: phaseIcon)
                        .font(.largeTitle)
                        .foregroundStyle(phaseColor)

                    if let timeRemaining = entry.timeRemaining, entry.isRunning {
                        Text(formatTime(timeRemaining))
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(Color.primary)
                    } else {
                        Text("Ready to Focus")
                            .font(.headline)
                            .foregroundStyle(Color.secondary)
                    }

                    Text(phaseName)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()

                // Stats section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("\(entry.completedPomodorosToday)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }

                    Text("Today's Focus")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)

                    if let officeName = entry.officeName {
                        HStack {
                            Image(systemName: "building.2.fill")
                                .font(.caption2)
                            Text(officeName)
                                .font(.caption2)
                        }
                        .foregroundStyle(Color.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
    }

    private var phaseColor: Color {
        guard let phase = entry.currentPhase else {
            return Color.gray
        }

        switch phase {
        case "work": return Color(red: 0.95, green: 0.26, blue: 0.21)
        case "short_break", "long_break": return Color(red: 0.20, green: 0.78, blue: 0.35)
        default: return Color.gray
        }
    }

    private var phaseIcon: String {
        guard let phase = entry.currentPhase else {
            return "timer"
        }

        switch phase {
        case "work": return "brain.head.profile"
        case "short_break": return "cup.and.saucer.fill"
        case "long_break": return "bed.double.fill"
        default: return "timer"
        }
    }

    private var phaseName: String {
        guard let phase = entry.currentPhase else {
            return "Pomodoro"
        }

        switch phase {
        case "work": return "Focus Time"
        case "short_break": return "Short Break"
        case "long_break": return "Long Break"
        default: return "Pomodoro"
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let entry: PomodoroWidgetEntry

    var body: some View {
        ZStack {
            phaseColor
                .opacity(0.2)

            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Pomodoro Timer")
                        .font(.headline)
                        .foregroundStyle(Color.primary)

                    Spacer()

                    if entry.isRunning {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(phaseColor)
                                .frame(width: 8, height: 8)
                            Text("Running")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }

                // Timer section
                VStack(spacing: 12) {
                    Image(systemName: phaseIcon)
                        .font(.system(size: 48))
                        .foregroundStyle(phaseColor)

                    if let timeRemaining = entry.timeRemaining, entry.isRunning {
                        Text(formatTime(timeRemaining))
                            .font(.system(size: 48, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(Color.primary)
                    } else {
                        Text("Ready to Focus")
                            .font(.title2)
                            .foregroundStyle(Color.secondary)
                    }

                    Text(phaseName)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxHeight: .infinity)

                Divider()

                // Stats section
                HStack(spacing: 24) {
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("\(entry.completedPomodorosToday)")
                                .font(.title)
                                .fontWeight(.bold)
                                .monospacedDigit()
                        }
                        Text("Completed Today")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    if let officeName = entry.officeName {
                        VStack {
                            HStack {
                                Image(systemName: "building.2.fill")
                                    .foregroundStyle(phaseColor)
                                Text(officeName)
                                    .font(.headline)
                                    .lineLimit(1)
                            }
                            Text("Current Office")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
        }
    }

    private var phaseColor: Color {
        guard let phase = entry.currentPhase else {
            return Color.gray
        }

        switch phase {
        case "work": return Color(red: 0.95, green: 0.26, blue: 0.21)
        case "short_break", "long_break": return Color(red: 0.20, green: 0.78, blue: 0.35)
        default: return Color.gray
        }
    }

    private var phaseIcon: String {
        guard let phase = entry.currentPhase else {
            return "timer"
        }

        switch phase {
        case "work": return "brain.head.profile"
        case "short_break": return "cup.and.saucer.fill"
        case "long_break": return "bed.double.fill"
        default: return "timer"
        }
    }

    private var phaseName: String {
        guard let phase = entry.currentPhase else {
            return "Pomodoro"
        }

        switch phase {
        case "work": return "Focus Time"
        case "short_break": return "Short Break"
        case "long_break": return "Long Break"
        default: return "Pomodoro"
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    PomodoroWidget()
} timeline: {
    PomodoroWidgetEntry(
        date: Date(),
        timeRemaining: 1500,
        currentPhase: "work",
        isRunning: true,
        completedPomodorosToday: 3,
        officeName: "My Office"
    )
    PomodoroWidgetEntry(
        date: Date(),
        timeRemaining: 300,
        currentPhase: "short_break",
        isRunning: true,
        completedPomodorosToday: 4,
        officeName: nil
    )
}

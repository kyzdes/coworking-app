import ActivityKit
import SwiftUI
import WidgetKit

/// Live Activity for Pomodoro timer
@available(iOS 16.1, *)
public struct PomodoroTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// Time remaining in seconds
        public var timeRemaining: TimeInterval

        /// Current phase of the timer
        public var phase: String

        /// Whether the timer is running or paused
        public var isRunning: Bool

        /// Total duration of current phase
        public var totalDuration: TimeInterval

        /// Number of completed pomodoros today
        public var completedPomodoros: Int

        public init(
            timeRemaining: TimeInterval,
            phase: String,
            isRunning: Bool,
            totalDuration: TimeInterval,
            completedPomodoros: Int
        ) {
            self.timeRemaining = timeRemaining
            self.phase = phase
            self.isRunning = isRunning
            self.totalDuration = totalDuration
            self.completedPomodoros = completedPomodoros
        }
    }

    /// Office name (if in an office)
    public var officeName: String?

    /// Session start time
    public var startTime: Date

    public init(officeName: String? = nil, startTime: Date = Date()) {
        self.officeName = officeName
        self.startTime = startTime
    }
}

@available(iOS 16.1, *)
public struct PomodoroLiveActivity: Widget {
    public init() {}

    public var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroTimerAttributes.self) { context in
            // Lock screen/banner UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    TimerIconView(phase: context.state.phase)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    CompletedPomodorosView(count: context.state.completedPomodoros)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(formatTime(context.state.timeRemaining))
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(phaseColor(context.state.phase))
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: progress(context.state))
                        .tint(phaseColor(context.state.phase))

                    if let officeName = context.attributes.officeName {
                        HStack {
                            Image(systemName: "building.2.fill")
                                .font(.caption2)
                            Text(officeName)
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                    }
                }
            } compactLeading: {
                TimerIconView(phase: context.state.phase)
            } compactTrailing: {
                Text(formatTime(context.state.timeRemaining))
                    .font(.caption2)
                    .monospacedDigit()
            } minimal: {
                TimerIconView(phase: context.state.phase)
            }
        }
    }

    // MARK: - Helper Functions

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    private func progress(_ state: PomodoroTimerAttributes.ContentState) -> Double {
        guard state.totalDuration > 0 else { return 0 }
        return 1 - (state.timeRemaining / state.totalDuration)
    }

    private func phaseColor(_ phase: String) -> Color {
        switch phase {
        case "work": return Color(red: 0.95, green: 0.26, blue: 0.21)
        case "short_break", "long_break": return Color(red: 0.20, green: 0.78, blue: 0.35)
        default: return .blue
        }
    }
}

// MARK: - Lock Screen View

@available(iOS 16.1, *)
private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<PomodoroTimerAttributes>

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TimerIconView(phase: context.state.phase)

                Text(phaseName(context.state.phase))
                    .font(.headline)

                Spacer()

                Text(formatTime(context.state.timeRemaining))
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }

            ProgressView(value: progress(context.state))
                .tint(phaseColor(context.state.phase))

            HStack {
                if let officeName = context.attributes.officeName {
                    Label(officeName, systemImage: "building.2.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Label("\(context.state.completedPomodoros)", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    private func progress(_ state: PomodoroTimerAttributes.ContentState) -> Double {
        guard state.totalDuration > 0 else { return 0 }
        return 1 - (state.timeRemaining / state.totalDuration)
    }

    private func phaseColor(_ phase: String) -> Color {
        switch phase {
        case "work": return Color(red: 0.95, green: 0.26, blue: 0.21)
        case "short_break", "long_break": return Color(red: 0.20, green: 0.78, blue: 0.35)
        default: return .blue
        }
    }

    private func phaseName(_ phase: String) -> String {
        switch phase {
        case "work": return "Focus Time"
        case "short_break": return "Short Break"
        case "long_break": return "Long Break"
        default: return "Pomodoro"
        }
    }
}

// MARK: - Supporting Views

@available(iOS 16.1, *)
private struct TimerIconView: View {
    let phase: String

    var body: some View {
        Image(systemName: iconName)
            .foregroundStyle(phaseColor(phase))
            .font(.headline)
    }

    private var iconName: String {
        switch phase {
        case "work": return "brain.head.profile"
        case "short_break": return "cup.and.saucer.fill"
        case "long_break": return "bed.double.fill"
        default: return "timer"
        }
    }

    private func phaseColor(_ phase: String) -> Color {
        switch phase {
        case "work": return Color(red: 0.95, green: 0.26, blue: 0.21)
        case "short_break", "long_break": return Color(red: 0.20, green: 0.78, blue: 0.35)
        default: return .blue
        }
    }
}

@available(iOS 16.1, *)
private struct CompletedPomodorosView: View {
    let count: Int

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("\(count)")
                .font(.caption2)
                .monospacedDigit()
        }
    }
}

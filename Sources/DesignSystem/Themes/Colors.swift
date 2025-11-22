import SwiftUI

/// App color palette supporting light and dark modes
public extension Color {
    // MARK: - Primary Colors

    /// Primary accent color (adaptive for Light/Dark mode)
    static let primaryAccent = Color("PrimaryAccent", bundle: .module)

    /// Pomodoro work session color
    static let pomodoroRed = Color(red: 0.95, green: 0.26, blue: 0.21)

    /// Break session color
    static let breakGreen = Color(red: 0.20, green: 0.78, blue: 0.35)

    /// Long break color
    static let breakBlue = Color(red: 0.20, green: 0.60, blue: 0.86)

    // MARK: - Semantic Colors

    /// Primary background color
    static let backgroundPrimary = Color(.systemBackground)

    /// Secondary background color (for cards, etc.)
    static let backgroundSecondary = Color(.secondarySystemBackground)

    /// Tertiary background color
    static let backgroundTertiary = Color(.tertiarySystemBackground)

    /// Primary label color
    static let labelPrimary = Color(.label)

    /// Secondary label color
    static let labelSecondary = Color(.secondaryLabel)

    /// Tertiary label color
    static let labelTertiary = Color(.tertiaryLabel)

    /// Quaternary label color
    static let labelQuaternary = Color(.quaternaryLabel)

    // MARK: - Status Colors

    /// Success state color
    static let success = Color.green

    /// Error state color
    static let error = Color.red

    /// Warning state color
    static let warning = Color.orange

    /// Info state color
    static let info = Color.blue

    // MARK: - User Status Colors

    /// Available status
    static let statusAvailable = Color.green

    /// In focus status
    static let statusInFocus = pomodoroRed

    /// On break status
    static let statusOnBreak = breakGreen

    /// Away status
    static let statusAway = Color.orange

    /// Offline status
    static let statusOffline = Color.gray

    // MARK: - Gradients

    /// Primary gradient for backgrounds
    static let primaryGradient = LinearGradient(
        colors: [pomodoroRed, pomodoroRed.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Success gradient
    static let successGradient = LinearGradient(
        colors: [breakGreen, breakGreen.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Background gradient
    static let backgroundGradient = LinearGradient(
        colors: [backgroundPrimary, backgroundSecondary],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Status Color Helper

public extension UserStatus {
    var color: Color {
        switch self {
        case .available:
            return .statusAvailable
        case .inFocus:
            return .statusInFocus
        case .onBreak:
            return .statusOnBreak
        case .away:
            return .statusAway
        case .offline:
            return .statusOffline
        }
    }
}

public extension SessionPhase {
    var color: Color {
        switch self {
        case .work:
            return .pomodoroRed
        case .shortBreak:
            return .breakGreen
        case .longBreak:
            return .breakBlue
        }
    }
}

import UserNotifications
import Foundation
import Dependencies

/// Service for managing local and push notifications
public actor NotificationService {
    private let center = UNUserNotificationCenter.current()

    public init() {}

    // MARK: - Permission Management

    /// Request notification permissions
    public func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    /// Check current authorization status
    public func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Local Notifications

    /// Schedule a notification for Pomodoro session completion
    public func scheduleSessionCompleteNotification(
        title: String,
        body: String,
        timeInterval: TimeInterval,
        phase: String
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        // Add category for actions
        content.categoryIdentifier = "POMODORO_COMPLETE"
        content.userInfo = ["phase": phase]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "pomodoro-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    /// Schedule break reminder notification
    public func scheduleBreakReminder(timeInterval: TimeInterval) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Break Time! 🎉"
        content.body = "Great work! Take a well-deserved break."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "break-reminder-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    /// Schedule work session start notification
    public func scheduleWorkSessionReminder(timeInterval: TimeInterval) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Back to Focus 🧠"
        content.body = "Break's over! Ready to dive back in?"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "work-reminder-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    /// Schedule daily motivation notification
    public func scheduleDailyMotivation(hour: Int, minute: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Ready to be productive?"
        content.body = "Start your first Pomodoro session of the day!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "daily-motivation",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    /// Schedule streak reminder
    public func scheduleStreakReminder(streak: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Keep Your Streak! 🔥"
        content.body = "You're on a \(streak) day streak. Don't break it!"
        content.sound = .default

        // Schedule for 8 PM if user hasn't completed any sessions today
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "streak-reminder",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    // MARK: - Friend Notifications

    /// Notify when a friend starts a session
    public func notifyFriendStartedSession(
        friendName: String,
        officeName: String?
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = "\(friendName) started a session"

        if let office = officeName {
            content.body = "Join them in \(office)!"
        } else {
            content.body = "Start your own session and work together!"
        }

        content.sound = .default
        content.categoryIdentifier = "FRIEND_SESSION"

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "friend-session-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    /// Notify when receiving a friend request
    public func notifyFriendRequest(from friendName: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = "New Friend Request"
        content.body = "\(friendName) wants to be your friend"
        content.sound = .default
        content.categoryIdentifier = "FRIEND_REQUEST"

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "friend-request-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    // MARK: - Notification Management

    /// Cancel all pending notifications
    public func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }

    /// Cancel specific notification by identifier
    public func cancelNotification(withIdentifier identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Get all pending notifications
    public func getPendingNotifications() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }

    /// Clear badge count
    public func clearBadge() {
        center.setBadgeCount(0)
    }

    // MARK: - Notification Categories

    /// Setup notification categories with actions
    public func setupNotificationCategories() {
        // Pomodoro complete actions
        let startBreakAction = UNNotificationAction(
            identifier: "START_BREAK",
            title: "Start Break",
            options: [.foreground]
        )

        let skipBreakAction = UNNotificationAction(
            identifier: "SKIP_BREAK",
            title: "Skip Break",
            options: []
        )

        let pomodoroCategory = UNNotificationCategory(
            identifier: "POMODORO_COMPLETE",
            actions: [startBreakAction, skipBreakAction],
            intentIdentifiers: [],
            options: []
        )

        // Friend session actions
        let joinSessionAction = UNNotificationAction(
            identifier: "JOIN_SESSION",
            title: "Join",
            options: [.foreground]
        )

        let friendSessionCategory = UNNotificationCategory(
            identifier: "FRIEND_SESSION",
            actions: [joinSessionAction],
            intentIdentifiers: [],
            options: []
        )

        // Friend request actions
        let acceptRequestAction = UNNotificationAction(
            identifier: "ACCEPT_REQUEST",
            title: "Accept",
            options: []
        )

        let declineRequestAction = UNNotificationAction(
            identifier: "DECLINE_REQUEST",
            title: "Decline",
            options: [.destructive]
        )

        let friendRequestCategory = UNNotificationCategory(
            identifier: "FRIEND_REQUEST",
            actions: [acceptRequestAction, declineRequestAction],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([
            pomodoroCategory,
            friendSessionCategory,
            friendRequestCategory
        ])
    }
}

// MARK: - Dependency

extension NotificationService: DependencyKey {
    public static let liveValue = NotificationService()
    public static let testValue = NotificationService()
}

extension DependencyValues {
    public var notificationService: NotificationService {
        get { self[NotificationService.self] }
        set { self[NotificationService.self] = newValue }
    }
}

import Foundation
import SwiftData

/// User model representing a registered user in the app
@Model
public final class User {
    @Attribute(.unique) public var id: UUID
    public var username: String
    public var email: String
    public var displayName: String
    public var avatarURL: URL?
    public var status: UserStatus
    public var createdAt: Date
    public var updatedAt: Date

    // Statistics
    public var totalFocusTime: TimeInterval
    public var completedSessions: Int
    public var currentStreak: Int

    // Relationships
    @Relationship(deleteRule: .cascade) public var sessions: [PomodoroSession]
    @Relationship(deleteRule: .nullify) public var offices: [Office]

    public init(
        id: UUID = UUID(),
        username: String,
        email: String,
        displayName: String,
        avatarURL: URL? = nil,
        status: UserStatus = .offline,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        totalFocusTime: TimeInterval = 0,
        completedSessions: Int = 0,
        currentStreak: Int = 0
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.totalFocusTime = totalFocusTime
        self.completedSessions = completedSessions
        self.currentStreak = currentStreak
        self.sessions = []
        self.offices = []
    }
}

// MARK: - User Status
public enum UserStatus: String, Codable, Sendable {
    case available = "available"
    case inFocus = "in_focus"
    case onBreak = "on_break"
    case away = "away"
    case offline = "offline"

    public var displayName: String {
        switch self {
        case .available: return "Available"
        case .inFocus: return "In Focus"
        case .onBreak: return "On Break"
        case .away: return "Away"
        case .offline: return "Offline"
        }
    }

    public var iconName: String {
        switch self {
        case .available: return "checkmark.circle.fill"
        case .inFocus: return "brain.head.profile"
        case .onBreak: return "cup.and.saucer.fill"
        case .away: return "moon.fill"
        case .offline: return "circle"
        }
    }
}

// MARK: - Equatable
extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension User: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

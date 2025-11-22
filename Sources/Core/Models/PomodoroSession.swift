import Foundation
import SwiftData

/// Represents a single Pomodoro session
@Model
public final class PomodoroSession {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var officeId: UUID?
    public var phase: SessionPhase
    public var startTime: Date
    public var endTime: Date?
    public var plannedDuration: TimeInterval
    public var actualDuration: TimeInterval?
    public var isCompleted: Bool
    public var wasInterrupted: Bool

    public init(
        id: UUID = UUID(),
        userId: UUID,
        officeId: UUID? = nil,
        phase: SessionPhase = .work,
        startTime: Date = Date(),
        endTime: Date? = nil,
        plannedDuration: TimeInterval,
        actualDuration: TimeInterval? = nil,
        isCompleted: Bool = false,
        wasInterrupted: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.officeId = officeId
        self.phase = phase
        self.startTime = startTime
        self.endTime = endTime
        self.plannedDuration = plannedDuration
        self.actualDuration = actualDuration
        self.isCompleted = isCompleted
        self.wasInterrupted = wasInterrupted
    }

    /// Mark session as completed
    public func complete() {
        self.endTime = Date()
        self.actualDuration = endTime?.timeIntervalSince(startTime)
        self.isCompleted = true
    }

    /// Mark session as interrupted
    public func interrupt() {
        self.endTime = Date()
        self.actualDuration = endTime?.timeIntervalSince(startTime)
        self.wasInterrupted = true
    }
}

// MARK: - Session Phase
public enum SessionPhase: String, Codable, Sendable {
    case work = "work"
    case shortBreak = "short_break"
    case longBreak = "long_break"

    public var displayName: String {
        switch self {
        case .work: return "Focus Time"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }

    public var iconName: String {
        switch self {
        case .work: return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer.fill"
        case .longBreak: return "bed.double.fill"
        }
    }

    public var defaultDuration: TimeInterval {
        switch self {
        case .work: return 25 * 60 // 25 minutes
        case .shortBreak: return 5 * 60 // 5 minutes
        case .longBreak: return 15 * 60 // 15 minutes
        }
    }
}

// MARK: - Timer Settings
public struct TimerSettings: Codable, Equatable, Sendable {
    public var workDuration: TimeInterval
    public var shortBreakDuration: TimeInterval
    public var longBreakDuration: TimeInterval
    public var sessionsUntilLongBreak: Int
    public var autoStartNextSession: Bool
    public var autoStartBreaks: Bool

    public static let `default` = TimerSettings(
        workDuration: 25 * 60,
        shortBreakDuration: 5 * 60,
        longBreakDuration: 15 * 60,
        sessionsUntilLongBreak: 4,
        autoStartNextSession: false,
        autoStartBreaks: false
    )

    public init(
        workDuration: TimeInterval,
        shortBreakDuration: TimeInterval,
        longBreakDuration: TimeInterval,
        sessionsUntilLongBreak: Int,
        autoStartNextSession: Bool,
        autoStartBreaks: Bool
    ) {
        self.workDuration = workDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
        self.sessionsUntilLongBreak = sessionsUntilLongBreak
        self.autoStartNextSession = autoStartNextSession
        self.autoStartBreaks = autoStartBreaks
    }
}

// MARK: - Equatable
extension PomodoroSession: Equatable {
    public static func == (lhs: PomodoroSession, rhs: PomodoroSession) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension PomodoroSession: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

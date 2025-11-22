import Foundation

// MARK: - Personal Statistics

public struct PersonalStatistics: Codable, Equatable {
    public let totalFocusTime: TimeInterval
    public let completedSessions: Int
    public let currentStreak: Int
    public let longestStreak: Int
    public let dailyStats: [DailyStats]
    public let weeklyStats: [WeeklyStats]
    public let productiveHours: [HourlyStats]

    public init(
        totalFocusTime: TimeInterval,
        completedSessions: Int,
        currentStreak: Int,
        longestStreak: Int,
        dailyStats: [DailyStats],
        weeklyStats: [WeeklyStats],
        productiveHours: [HourlyStats]
    ) {
        self.totalFocusTime = totalFocusTime
        self.completedSessions = completedSessions
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.dailyStats = dailyStats
        self.weeklyStats = weeklyStats
        self.productiveHours = productiveHours
    }
}

// MARK: - Daily Statistics

public struct DailyStats: Codable, Equatable, Identifiable {
    public let date: Date
    public let completedPomodoros: Int
    public let focusTime: TimeInterval
    public let breakTime: TimeInterval

    public var id: Date { date }

    public init(
        date: Date,
        completedPomodoros: Int,
        focusTime: TimeInterval,
        breakTime: TimeInterval
    ) {
        self.date = date
        self.completedPomodoros = completedPomodoros
        self.focusTime = focusTime
        self.breakTime = breakTime
    }
}

// MARK: - Weekly Statistics

public struct WeeklyStats: Codable, Equatable, Identifiable {
    public let weekStart: Date
    public let weekEnd: Date
    public let completedPomodoros: Int
    public let totalFocusTime: TimeInterval
    public let averageDailyPomodoros: Double

    public var id: Date { weekStart }

    public init(
        weekStart: Date,
        weekEnd: Date,
        completedPomodoros: Int,
        totalFocusTime: TimeInterval,
        averageDailyPomodoros: Double
    ) {
        self.weekStart = weekStart
        self.weekEnd = weekEnd
        self.completedPomodoros = completedPomodoros
        self.totalFocusTime = totalFocusTime
        self.averageDailyPomodoros = averageDailyPomodoros
    }
}

// MARK: - Hourly Statistics

public struct HourlyStats: Codable, Equatable, Identifiable {
    public let hour: Int
    public let completedPomodoros: Int

    public var id: Int { hour }

    public init(hour: Int, completedPomodoros: Int) {
        self.hour = hour
        self.completedPomodoros = completedPomodoros
    }
}

// MARK: - Office Statistics

public struct OfficeStatistics: Codable, Equatable {
    public let officeId: UUID
    public let officeName: String
    public let totalFocusTime: TimeInterval
    public let completedSessions: Int
    public let memberStats: [MemberStats]
    public let dailyActivity: [DailyActivityStats]

    public init(
        officeId: UUID,
        officeName: String,
        totalFocusTime: TimeInterval,
        completedSessions: Int,
        memberStats: [MemberStats],
        dailyActivity: [DailyActivityStats]
    ) {
        self.officeId = officeId
        self.officeName = officeName
        self.totalFocusTime = totalFocusTime
        self.completedSessions = completedSessions
        self.memberStats = memberStats
        self.dailyActivity = dailyActivity
    }
}

// MARK: - Member Statistics

public struct MemberStats: Codable, Equatable, Identifiable {
    public let userId: UUID
    public let username: String
    public let completedPomodoros: Int
    public let totalFocusTime: TimeInterval

    public var id: UUID { userId }

    public init(
        userId: UUID,
        username: String,
        completedPomodoros: Int,
        totalFocusTime: TimeInterval
    ) {
        self.userId = userId
        self.username = username
        self.completedPomodoros = completedPomodoros
        self.totalFocusTime = totalFocusTime
    }
}

// MARK: - Daily Activity Statistics

public struct DailyActivityStats: Codable, Equatable, Identifiable {
    public let date: Date
    public let activeMembers: Int
    public let totalPomodoros: Int

    public var id: Date { date }

    public init(
        date: Date,
        activeMembers: Int,
        totalPomodoros: Int
    ) {
        self.date = date
        self.activeMembers = activeMembers
        self.totalPomodoros = totalPomodoros
    }
}

// MARK: - Statistics Period

public enum StatisticsPeriod: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"

    public var id: String { rawValue }
}

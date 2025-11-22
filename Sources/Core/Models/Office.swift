import Foundation
import SwiftData

/// Virtual office where users can work together
@Model
public final class Office {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var officDescription: String
    public var ownerId: UUID
    public var createdAt: Date
    public var updatedAt: Date
    public var isArchived: Bool

    // Relationships
    @Relationship(deleteRule: .cascade) public var members: [OfficeMember]

    public init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        ownerId: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.officDescription = description
        self.ownerId = ownerId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
        self.members = []
    }

    /// Maximum number of members allowed in an office
    public static let maxMembers = 20

    /// Check if office is at capacity
    public var isFull: Bool {
        members.count >= Self.maxMembers
    }

    /// Get active members count
    public var activeMembersCount: Int {
        members.filter { !$0.leftAt.map { _ in true } ?? false }.count
    }
}

// MARK: - Office Member
@Model
public final class OfficeMember {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var officeId: UUID
    public var role: MemberRole
    public var joinedAt: Date
    public var leftAt: Date?

    // Current session info
    public var currentStatus: UserStatus
    public var timeRemaining: TimeInterval?
    public var completedPomodorosToday: Int

    public init(
        id: UUID = UUID(),
        userId: UUID,
        officeId: UUID,
        role: MemberRole = .member,
        joinedAt: Date = Date(),
        leftAt: Date? = nil,
        currentStatus: UserStatus = .offline,
        timeRemaining: TimeInterval? = nil,
        completedPomodorosToday: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.officeId = officeId
        self.role = role
        self.joinedAt = joinedAt
        self.leftAt = leftAt
        self.currentStatus = currentStatus
        self.timeRemaining = timeRemaining
        self.completedPomodorosToday = completedPomodorosToday
    }
}

// MARK: - Member Role
public enum MemberRole: String, Codable, Sendable {
    case owner = "owner"
    case member = "member"

    public var displayName: String {
        switch self {
        case .owner: return "Owner"
        case .member: return "Member"
        }
    }

    public var canManageOffice: Bool {
        self == .owner
    }
}

// MARK: - Equatable
extension Office: Equatable {
    public static func == (lhs: Office, rhs: Office) -> Bool {
        lhs.id == rhs.id
    }
}

extension OfficeMember: Equatable {
    public static func == (lhs: OfficeMember, rhs: OfficeMember) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension Office: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension OfficeMember: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

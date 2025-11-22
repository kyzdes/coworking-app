import Foundation
import SwiftData

/// Represents a friendship between two users
@Model
public final class Friendship {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var friendId: UUID
    public var status: FriendshipStatus
    public var createdAt: Date
    public var acceptedAt: Date?

    public init(
        id: UUID = UUID(),
        userId: UUID,
        friendId: UUID,
        status: FriendshipStatus = .pending,
        createdAt: Date = Date(),
        acceptedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.friendId = friendId
        self.status = status
        self.createdAt = createdAt
        self.acceptedAt = acceptedAt
    }

    /// Accept the friendship request
    public func accept() {
        self.status = .accepted
        self.acceptedAt = Date()
    }

    /// Decline the friendship request
    public func decline() {
        self.status = .declined
    }
}

// MARK: - Friendship Status
public enum FriendshipStatus: String, Codable, Sendable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case blocked = "blocked"

    public var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Friends"
        case .declined: return "Declined"
        case .blocked: return "Blocked"
        }
    }
}

// MARK: - Equatable
extension Friendship: Equatable {
    public static func == (lhs: Friendship, rhs: Friendship) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension Friendship: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

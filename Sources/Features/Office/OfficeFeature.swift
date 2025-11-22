import Foundation
import ComposableArchitecture

@Reducer
public struct OfficeListFeature {
    @ObservableState
    public struct State: Equatable {
        public var offices: [Office] = []
        public var isLoading: Bool = false
        public var error: String?

        public init() {}
    }

    public enum Action: Equatable {
        case loadOffices
        case officesLoaded(Result<[Office], Error>)
        case createOfficeButtonTapped
        case officeSelected(Office)
        case refreshOffices

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.loadOffices, .loadOffices): return true
            case (.createOfficeButtonTapped, .createOfficeButtonTapped): return true
            case (.refreshOffices, .refreshOffices): return true
            case (.officeSelected(let l), .officeSelected(let r)): return l == r
            case (.officesLoaded(.success(let l)), .officesLoaded(.success(let r))): return l == r
            case (.officesLoaded(.failure), .officesLoaded(.failure)): return true
            default: return false
            }
        }
    }

    @Dependency(\.networkService) var networkService

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadOffices, .refreshOffices:
                state.isLoading = true
                state.error = nil

                return .run { send in
                    await send(.officesLoaded(
                        Result {
                            let endpoint = Endpoint.getOffices()
                            return try await networkService.request(endpoint, type: [Office].self)
                        }
                    ))
                }

            case .officesLoaded(.success(let offices)):
                state.isLoading = false
                state.offices = offices
                return .none

            case .officesLoaded(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none

            case .createOfficeButtonTapped:
                // Will navigate to create office screen
                return .none

            case .officeSelected:
                // Will navigate to office detail screen
                return .none
            }
        }
    }
}

// MARK: - Office Detail Feature

@Reducer
public struct OfficeDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var office: Office
        public var members: [OfficeMemberDetail] = []
        public var isLoading: Bool = false
        public var error: String?

        public init(office: Office) {
            self.office = office
        }
    }

    public enum Action: Equatable {
        case loadMembers
        case membersLoaded(Result<[OfficeMemberDetail], Error>)
        case addMemberButtonTapped
        case memberStatusUpdated(OfficeMemberStatusMessage)
        case memberJoined(OfficeMemberJoinedMessage)
        case memberLeft(OfficeMemberLeftMessage)

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.loadMembers, .loadMembers): return true
            case (.addMemberButtonTapped, .addMemberButtonTapped): return true
            case (.membersLoaded(.success(let l)), .membersLoaded(.success(let r))): return l == r
            case (.membersLoaded(.failure), .membersLoaded(.failure)): return true
            case (.memberStatusUpdated(let l), .memberStatusUpdated(let r)): return l == r
            case (.memberJoined(let l), .memberJoined(let r)): return l == r
            case (.memberLeft(let l), .memberLeft(let r)): return l == r
            default: return false
            }
        }
    }

    @Dependency(\.networkService) var networkService

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadMembers:
                state.isLoading = true
                state.error = nil

                return .run { [officeId = state.office.id] send in
                    await send(.membersLoaded(
                        Result {
                            let endpoint = Endpoint.getOffice(id: officeId)
                            let response: OfficeDetailResponse = try await networkService.request(
                                endpoint,
                                type: OfficeDetailResponse.self
                            )
                            return response.members
                        }
                    ))
                }

            case .membersLoaded(.success(let members)):
                state.isLoading = false
                state.members = members
                return .none

            case .membersLoaded(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none

            case .addMemberButtonTapped:
                // Will show add member sheet
                return .none

            case .memberStatusUpdated(let message):
                // Update member status in real-time
                if let index = state.members.firstIndex(where: { $0.userId == message.userId }) {
                    state.members[index].status = message.status
                    state.members[index].timeRemaining = message.timeRemaining
                }
                return .none

            case .memberJoined(let message):
                // Add new member to the list
                let newMember = OfficeMemberDetail(
                    userId: message.userId,
                    username: message.username,
                    status: .available,
                    timeRemaining: nil,
                    completedPomodorosToday: 0
                )
                state.members.append(newMember)
                return .none

            case .memberLeft(let message):
                // Remove member from the list
                state.members.removeAll { $0.userId == message.userId }
                return .none
            }
        }
    }
}

// MARK: - Supporting Types

public struct OfficeMemberDetail: Codable, Equatable, Identifiable {
    public let userId: UUID
    public let username: String
    public var status: UserStatus
    public var timeRemaining: TimeInterval?
    public var completedPomodorosToday: Int
    public var avatarURL: URL?

    public var id: UUID { userId }

    public init(
        userId: UUID,
        username: String,
        status: UserStatus,
        timeRemaining: TimeInterval?,
        completedPomodorosToday: Int,
        avatarURL: URL? = nil
    ) {
        self.userId = userId
        self.username = username
        self.status = status
        self.timeRemaining = timeRemaining
        self.completedPomodorosToday = completedPomodorosToday
        self.avatarURL = avatarURL
    }
}

struct OfficeDetailResponse: Codable {
    let office: Office
    let members: [OfficeMemberDetail]
}

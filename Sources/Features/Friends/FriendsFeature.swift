import Foundation
import ComposableArchitecture

@Reducer
public struct FriendsFeature {
    @ObservableState
    public struct State: Equatable {
        public var friends: [FriendInfo] = []
        public var pendingRequests: [FriendInfo] = []
        public var searchQuery: String = ""
        public var searchResults: [FriendInfo] = []
        public var isLoading: Bool = false
        public var isSearching: Bool = false
        public var error: String?
        public var showQRScanner: Bool = false
        public var qrCodeImage: UIImage?

        public init() {}
    }

    public enum Action: Equatable {
        case loadFriends
        case loadPendingRequests
        case friendsLoaded(Result<[FriendInfo], Error>)
        case pendingRequestsLoaded(Result<[FriendInfo], Error>)
        case searchQueryChanged(String)
        case searchFriends
        case searchResultsLoaded(Result<[FriendInfo], Error>)
        case sendFriendRequest(UUID)
        case acceptFriendRequest(UUID)
        case declineFriendRequest(UUID)
        case removeFriend(UUID)
        case requestCompleted(Result<Void, Error>)
        case showQRScannerTapped
        case dismissQRScanner
        case qrCodeScanned(String)
        case generateQRCode
        case qrCodeGenerated(UIImage?)

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.loadFriends, .loadFriends): return true
            case (.loadPendingRequests, .loadPendingRequests): return true
            case (.searchFriends, .searchFriends): return true
            case (.searchQueryChanged(let l), .searchQueryChanged(let r)): return l == r
            case (.sendFriendRequest(let l), .sendFriendRequest(let r)): return l == r
            case (.acceptFriendRequest(let l), .acceptFriendRequest(let r)): return l == r
            case (.declineFriendRequest(let l), .declineFriendRequest(let r)): return l == r
            case (.removeFriend(let l), .removeFriend(let r)): return l == r
            case (.showQRScannerTapped, .showQRScannerTapped): return true
            case (.dismissQRScanner, .dismissQRScanner): return true
            case (.qrCodeScanned(let l), .qrCodeScanned(let r)): return l == r
            case (.generateQRCode, .generateQRCode): return true
            case (.friendsLoaded(.success(let l)), .friendsLoaded(.success(let r))): return l == r
            case (.friendsLoaded(.failure), .friendsLoaded(.failure)): return true
            case (.pendingRequestsLoaded(.success(let l)), .pendingRequestsLoaded(.success(let r))): return l == r
            case (.pendingRequestsLoaded(.failure), .pendingRequestsLoaded(.failure)): return true
            case (.searchResultsLoaded(.success(let l)), .searchResultsLoaded(.success(let r))): return l == r
            case (.searchResultsLoaded(.failure), .searchResultsLoaded(.failure)): return true
            case (.requestCompleted(.success), .requestCompleted(.success)): return true
            case (.requestCompleted(.failure), .requestCompleted(.failure)): return true
            case (.qrCodeGenerated, .qrCodeGenerated): return true
            default: return false
            }
        }
    }

    @Dependency(\.networkService) var networkService
    @Dependency(\.qrCodeService) var qrCodeService
    @Dependency(\.authManager) var authManager

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadFriends:
                state.isLoading = true
                state.error = nil

                return .run { send in
                    await send(.friendsLoaded(
                        Result {
                            let endpoint = Endpoint.getFriends()
                            return try await networkService.request(endpoint, type: [FriendInfo].self)
                        }
                    ))
                }

            case .loadPendingRequests:
                return .run { send in
                    await send(.pendingRequestsLoaded(
                        Result {
                            // TODO: Add endpoint for pending requests
                            return []
                        }
                    ))
                }

            case .friendsLoaded(.success(let friends)):
                state.isLoading = false
                state.friends = friends
                return .none

            case .friendsLoaded(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none

            case .pendingRequestsLoaded(.success(let requests)):
                state.pendingRequests = requests
                return .none

            case .pendingRequestsLoaded(.failure):
                return .none

            case .searchQueryChanged(let query):
                state.searchQuery = query
                if query.isEmpty {
                    state.searchResults = []
                    state.isSearching = false
                }
                return .none

            case .searchFriends:
                guard !state.searchQuery.isEmpty else {
                    state.searchResults = []
                    return .none
                }

                state.isSearching = true

                return .run { [query = state.searchQuery] send in
                    await send(.searchResultsLoaded(
                        Result {
                            let endpoint = Endpoint.searchUsers(query: query)
                            return try await networkService.request(endpoint, type: [FriendInfo].self)
                        }
                    ))
                }

            case .searchResultsLoaded(.success(let results)):
                state.isSearching = false
                state.searchResults = results
                return .none

            case .searchResultsLoaded(.failure(let error)):
                state.isSearching = false
                state.error = error.localizedDescription
                return .none

            case .sendFriendRequest(let userId):
                return .run { send in
                    await send(.requestCompleted(
                        Result {
                            let endpoint = Endpoint.inviteFriend(userId: userId)
                            try await networkService.request(endpoint)
                        }
                    ))
                }

            case .acceptFriendRequest(let friendshipId):
                return .run { send in
                    await send(.requestCompleted(
                        Result {
                            let endpoint = Endpoint.acceptFriend(friendshipId: friendshipId)
                            try await networkService.request(endpoint)
                        }
                    ))
                }

            case .declineFriendRequest(let friendshipId):
                state.pendingRequests.removeAll { $0.id == friendshipId }
                return .none

            case .removeFriend(let userId):
                state.friends.removeAll { $0.id == userId }
                return .run { send in
                    await send(.requestCompleted(
                        Result {
                            let endpoint = Endpoint.removeFriend(friendId: userId)
                            try await networkService.request(endpoint)
                        }
                    ))
                }

            case .requestCompleted(.success):
                return .merge(
                    .send(.loadFriends),
                    .send(.loadPendingRequests)
                )

            case .requestCompleted(.failure(let error)):
                state.error = error.localizedDescription
                return .none

            case .showQRScannerTapped:
                state.showQRScanner = true
                return .none

            case .dismissQRScanner:
                state.showQRScanner = false
                return .none

            case .qrCodeScanned(let urlString):
                state.showQRScanner = false

                return .run { send in
                    if let userId = await qrCodeService.parseInviteURL(urlString) {
                        await send(.sendFriendRequest(userId))
                    }
                }

            case .generateQRCode:
                return .run { send in
                    if let currentUser = await authManager.getCurrentUser(),
                       let qrCode = await qrCodeService.generateQRCode(for: currentUser.id) {
                        await send(.qrCodeGenerated(qrCode))
                    }
                }

            case .qrCodeGenerated(let image):
                state.qrCodeImage = image
                return .none
            }
        }
    }
}

// MARK: - Friend Info

public struct FriendInfo: Codable, Equatable, Identifiable {
    public let id: UUID
    public let username: String
    public let displayName: String
    public let avatarURL: URL?
    public let status: UserStatus
    public let currentOffice: String?

    public init(
        id: UUID,
        username: String,
        displayName: String,
        avatarURL: URL?,
        status: UserStatus,
        currentOffice: String?
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.status = status
        self.currentOffice = currentOffice
    }
}

import SwiftUI
import ComposableArchitecture

public struct FriendsView: View {
    @Perception.Bindable var store: StoreOf<FriendsFeature>
    @State private var showQRShare = false

    public init(store: StoreOf<FriendsFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack(spacing: 0) {
                    // Search bar
                    searchBar

                    if store.isSearching || !store.searchResults.isEmpty {
                        searchResultsList
                    } else {
                        friendsList
                    }
                }
                .background(Color.backgroundPrimary)
                .navigationTitle("Friends")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                showQRShare = true
                                store.send(.generateQRCode)
                            } label: {
                                Label("Share QR Code", systemImage: "qrcode")
                            }

                            Button {
                                store.send(.showQRScannerTapped)
                            } label: {
                                Label("Scan QR Code", systemImage: "qrcode.viewfinder")
                            }
                        } label: {
                            Image(systemName: "person.badge.plus")
                        }
                    }
                }
                .sheet(isPresented: $showQRShare) {
                    QRCodeShareView(
                        qrCodeImage: store.qrCodeImage,
                        username: "username" // TODO: Get from current user
                    )
                }
                .sheet(isPresented: $store.showQRScanner.sending(\.dismissQRScanner)) {
                    QRCodeScannerView(
                        isPresented: $store.showQRScanner.sending(\.dismissQRScanner),
                        onCodeScanned: { code in
                            store.send(.qrCodeScanned(code))
                        }
                    )
                }
                .onAppear {
                    if store.friends.isEmpty {
                        store.send(.loadFriends)
                        store.send(.loadPendingRequests)
                    }
                }
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.labelTertiary)

            TextField("Search friends...", text: $store.searchQuery.sending(\.searchQueryChanged))
                .textFieldStyle(.plain)
                .autocapitalization(.none)
                .onSubmit {
                    store.send(.searchFriends)
                }

            if !store.searchQuery.isEmpty {
                Button {
                    store.send(.searchQueryChanged(""))
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.labelTertiary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.backgroundSecondary)
        .cornerRadius(CornerRadius.md)
        .padding(Spacing.lg)
    }

    private var friendsList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.lg) {
                // Pending requests section
                if !store.pendingRequests.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Pending Requests")
                            .font(.bodyHeadline)
                            .foregroundStyle(Color.labelPrimary)
                            .padding(.horizontal, Spacing.lg)

                        ForEach(store.pendingRequests) { request in
                            PendingRequestRow(request: request) {
                                store.send(.acceptFriendRequest(request.id))
                            } onDecline: {
                                store.send(.declineFriendRequest(request.id))
                            }
                        }
                    }
                }

                // Friends section
                if store.friends.isEmpty {
                    emptyState
                } else {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Friends")
                            .font(.bodyHeadline)
                            .foregroundStyle(Color.labelPrimary)
                            .padding(.horizontal, Spacing.lg)

                        ForEach(store.friends) { friend in
                            FriendRow(friend: friend)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.send(.removeFriend(friend.id))
                                    } label: {
                                        Label("Remove Friend", systemImage: "person.fill.xmark")
                                    }
                                }
                        }
                    }
                }
            }
            .padding(.vertical, Spacing.lg)
        }
    }

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                if store.isSearching {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.xxxl)
                } else if store.searchResults.isEmpty {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.labelTertiary)

                        Text("No users found")
                            .font(.bodyHeadline)
                            .foregroundStyle(Color.labelSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.xxxl)
                } else {
                    ForEach(store.searchResults) { user in
                        SearchResultRow(user: user) {
                            store.send(.sendFriendRequest(user.id))
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                }
            }
            .padding(.vertical, Spacing.lg)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "person.2")
                .font(.system(size: 64))
                .foregroundStyle(Color.labelTertiary)

            Text("No Friends Yet")
                .font(.displayTitle3)
                .foregroundStyle(Color.labelPrimary)

            Text("Add friends to work together in virtual offices")
                .font(.bodyRegular)
                .foregroundStyle(Color.labelSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxxl)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.huge)
    }
}

// MARK: - Friend Row

private struct FriendRow: View {
    let friend: FriendInfo

    var body: some View {
        Card {
            HStack(spacing: Spacing.md) {
                UserAvatar(
                    url: friend.avatarURL,
                    size: AvatarSize.md,
                    status: friend.status,
                    initials: String(friend.displayName.prefix(2).uppercased())
                )

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(friend.displayName)
                        .font(.bodyHeadline)
                        .foregroundStyle(Color.labelPrimary)

                    Text("@\(friend.username)")
                        .font(.captionPrimary)
                        .foregroundStyle(Color.labelSecondary)

                    if let office = friend.currentOffice {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "building.2.fill")
                                .font(.caption2)
                            Text(office)
                                .font(.caption2)
                        }
                        .foregroundStyle(Color.labelTertiary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.labelTertiary)
            }
        }
        .padding(.horizontal, Spacing.lg)
    }
}

// MARK: - Pending Request Row

private struct PendingRequestRow: View {
    let request: FriendInfo
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        Card {
            HStack(spacing: Spacing.md) {
                UserAvatar(
                    url: request.avatarURL,
                    size: AvatarSize.md,
                    showStatusIndicator: false,
                    initials: String(request.displayName.prefix(2).uppercased())
                )

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(request.displayName)
                        .font(.bodyHeadline)
                        .foregroundStyle(Color.labelPrimary)

                    Text("@\(request.username)")
                        .font(.captionPrimary)
                        .foregroundStyle(Color.labelSecondary)
                }

                Spacer()

                HStack(spacing: Spacing.sm) {
                    Button {
                        onDecline()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundStyle(Color.error)
                            .frame(width: 36, height: 36)
                            .background(Color.error.opacity(0.1))
                            .cornerRadius(CornerRadius.md)
                    }

                    Button {
                        onAccept()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundStyle(Color.success)
                            .frame(width: 36, height: 36)
                            .background(Color.success.opacity(0.1))
                            .cornerRadius(CornerRadius.md)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
    }
}

// MARK: - Search Result Row

private struct SearchResultRow: View {
    let user: FriendInfo
    let onAdd: () -> Void

    var body: some View {
        Card {
            HStack(spacing: Spacing.md) {
                UserAvatar(
                    url: user.avatarURL,
                    size: AvatarSize.md,
                    showStatusIndicator: false,
                    initials: String(user.displayName.prefix(2).uppercased())
                )

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(user.displayName)
                        .font(.bodyHeadline)
                        .foregroundStyle(Color.labelPrimary)

                    Text("@\(user.username)")
                        .font(.captionPrimary)
                        .foregroundStyle(Color.labelSecondary)
                }

                Spacer()

                Button {
                    onAdd()
                } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.title3)
                        .foregroundStyle(Color.primaryAccent)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    FriendsView(
        store: Store(initialState: FriendsFeature.State()) {
            FriendsFeature()
        }
    )
}

import SwiftUI

/// User avatar component with status indicator
public struct UserAvatar: View {
    private let url: URL?
    private let size: CGFloat
    private let status: UserStatus?
    private let showStatusIndicator: Bool
    private let initials: String?

    public init(
        url: URL? = nil,
        size: CGFloat = AvatarSize.md,
        status: UserStatus? = nil,
        showStatusIndicator: Bool = true,
        initials: String? = nil
    ) {
        self.url = url
        self.size = size
        self.status = status
        self.showStatusIndicator = showStatusIndicator
        self.initials = initials
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Avatar image or initials
            Group {
                if let url = url {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            placeholderView
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            placeholderView
                        @unknown default:
                            placeholderView
                        }
                    }
                } else {
                    placeholderView
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(Color.backgroundPrimary, lineWidth: 2)
            )

            // Status indicator
            if showStatusIndicator, let status = status {
                StatusIndicator(status: status, size: size * 0.3)
                    .offset(x: 2, y: 2)
            }
        }
    }

    private var placeholderView: some View {
        ZStack {
            Circle()
                .fill(Color.primaryAccent.opacity(0.2))

            if let initials = initials {
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundStyle(Color.primaryAccent)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.5))
                    .foregroundStyle(Color.labelTertiary)
            }
        }
    }
}

// MARK: - Status Indicator

private struct StatusIndicator: View {
    let status: UserStatus
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(status.color)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .strokeBorder(Color.backgroundPrimary, lineWidth: 2)
            )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.xl) {
        HStack(spacing: Spacing.lg) {
            UserAvatar(
                size: AvatarSize.sm,
                status: .available,
                initials: "JD"
            )

            UserAvatar(
                size: AvatarSize.md,
                status: .inFocus,
                initials: "AB"
            )

            UserAvatar(
                size: AvatarSize.lg,
                status: .onBreak,
                initials: "CD"
            )

            UserAvatar(
                size: AvatarSize.xl,
                status: .away,
                initials: "EF"
            )
        }

        HStack(spacing: Spacing.lg) {
            UserAvatar(
                size: AvatarSize.md,
                status: .offline,
                showStatusIndicator: false,
                initials: "GH"
            )

            UserAvatar(
                size: AvatarSize.md,
                initials: "IJ"
            )

            UserAvatar(
                size: AvatarSize.md,
                status: .inFocus
            )
        }
    }
    .padding()
}

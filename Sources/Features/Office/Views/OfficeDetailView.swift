import SwiftUI
import ComposableArchitecture

public struct OfficeDetailView: View {
    @Perception.Bindable var store: StoreOf<OfficeDetailFeature>

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    public init(store: StoreOf<OfficeDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Office info
                    Card {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text(store.office.name)
                                .font(.displayTitle3)
                                .foregroundStyle(Color.labelPrimary)

                            if !store.office.officDescription.isEmpty {
                                Text(store.office.officDescription)
                                    .font(.bodyRegular)
                                    .foregroundStyle(Color.labelSecondary)
                            }

                            HStack {
                                Image(systemName: "person.2.fill")
                                    .foregroundStyle(Color.labelSecondary)

                                Text("\(store.members.count)/\(Office.maxMembers) members")
                                    .font(.bodyCallout)
                                    .foregroundStyle(Color.labelSecondary)
                            }
                        }
                    }

                    // Members grid
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        HStack {
                            Text("Members")
                                .font(.bodyHeadline)
                                .foregroundStyle(Color.labelPrimary)

                            Spacer()

                            Button {
                                store.send(.addMemberButtonTapped)
                            } label: {
                                Image(systemName: "person.badge.plus")
                                    .foregroundStyle(Color.primaryAccent)
                            }
                        }

                        if store.isLoading && store.members.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(Spacing.xxxl)
                        } else if store.members.isEmpty {
                            Text("No members yet")
                                .font(.bodyRegular)
                                .foregroundStyle(Color.labelSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(Spacing.xxxl)
                        } else {
                            LazyVGrid(columns: columns, spacing: Spacing.lg) {
                                ForEach(store.members) { member in
                                    MemberCard(member: member)
                                }
                            }
                        }
                    }
                }
                .padding(Spacing.lg)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Office")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                store.send(.loadMembers)
            }
        }
    }
}

// MARK: - Member Card

private struct MemberCard: View {
    let member: OfficeMemberDetail

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Avatar
            UserAvatar(
                url: member.avatarURL,
                size: AvatarSize.lg,
                status: member.status,
                initials: String(member.username.prefix(2).uppercased())
            )

            // Username
            Text(member.username)
                .font(.bodyCallout)
                .foregroundStyle(Color.labelPrimary)
                .lineLimit(1)

            // Status
            VStack(spacing: Spacing.xs) {
                if member.status == .inFocus || member.status == .onBreak,
                   let timeRemaining = member.timeRemaining {
                    Text(formatTime(timeRemaining))
                        .font(.captionPrimary)
                        .foregroundStyle(Color.labelSecondary)
                        .monospacedDigit()
                }

                // Completed pomodoros
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.success)

                    Text("\(member.completedPomodorosToday)")
                        .font(.captionSecondary)
                        .foregroundStyle(Color.labelSecondary)
                }
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .background(Color.backgroundSecondary)
        .cornerRadius(CornerRadius.lg)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        OfficeDetailView(
            store: Store(
                initialState: OfficeDetailFeature.State(
                    office: Office(
                        name: "My Office",
                        description: "A productive workspace",
                        ownerId: UUID()
                    )
                )
            ) {
                OfficeDetailFeature()
            }
        )
    }
}

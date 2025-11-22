import SwiftUI
import ComposableArchitecture

public struct OfficeListView: View {
    @Perception.Bindable var store: StoreOf<OfficeListFeature>

    public init(store: StoreOf<OfficeListFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ZStack {
                    if store.isLoading && store.offices.isEmpty {
                        ProgressView()
                    } else if store.offices.isEmpty {
                        emptyState
                    } else {
                        officesList
                    }
                }
                .navigationTitle("Offices")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            store.send(.createOfficeButtonTapped)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color.primaryAccent)
                        }
                    }
                }
                .refreshable {
                    store.send(.refreshOffices)
                }
                .onAppear {
                    if store.offices.isEmpty {
                        store.send(.loadOffices)
                    }
                }
            }
        }
    }

    private var officesList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.lg) {
                ForEach(store.offices) { office in
                    OfficeCard(office: office) {
                        store.send(.officeSelected(office))
                    }
                }
            }
            .padding(Spacing.lg)
        }
        .background(Color.backgroundPrimary)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "building.2")
                .font(.system(size: 64))
                .foregroundStyle(Color.labelTertiary)

            Text("No Offices Yet")
                .font(.displayTitle3)
                .foregroundStyle(Color.labelPrimary)

            Text("Create your first virtual office to start working with friends")
                .font(.bodyRegular)
                .foregroundStyle(Color.labelSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxxl)

            PrimaryButton("Create Office", icon: "plus.circle.fill") {
                store.send(.createOfficeButtonTapped)
            }
            .padding(.horizontal, Spacing.xxxl)
            .padding(.top, Spacing.lg)
        }
    }
}

// MARK: - Office Card

private struct OfficeCard: View {
    let office: Office
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(office.name)
                                .font(.bodyHeadline)
                                .foregroundStyle(Color.labelPrimary)

                            if !office.officDescription.isEmpty {
                                Text(office.officDescription)
                                    .font(.captionPrimary)
                                    .foregroundStyle(Color.labelSecondary)
                                    .lineLimit(2)
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(Color.labelTertiary)
                    }

                    // Members preview
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "person.2.fill")
                            .font(.captionPrimary)
                            .foregroundStyle(Color.labelSecondary)

                        Text("\(office.activeMembersCount) members")
                            .font(.captionPrimary)
                            .foregroundStyle(Color.labelSecondary)

                        Spacer()

                        // Active indicator
                        if office.activeMembersCount > 0 {
                            HStack(spacing: Spacing.xs) {
                                Circle()
                                    .fill(Color.success)
                                    .frame(width: 8, height: 8)

                                Text("Active")
                                    .font(.captionSecondary)
                                    .foregroundStyle(Color.labelSecondary)
                            }
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    OfficeListView(
        store: Store(
            initialState: OfficeListFeature.State()
        ) {
            OfficeListFeature()
        }
    )
}

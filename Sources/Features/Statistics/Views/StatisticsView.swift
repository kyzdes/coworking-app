import SwiftUI
import Charts
import ComposableArchitecture

public struct StatisticsView: View {
    @Perception.Bindable var store: StoreOf<StatisticsFeature>

    public init(store: StoreOf<StatisticsFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Period selector
                        periodSelector

                        if store.isLoading && store.statistics == nil {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 200)
                        } else if let stats = store.statistics {
                            // Quick stats cards
                            quickStatsSection(stats: stats)

                            // Daily chart
                            dailyChartSection(stats: stats)

                            // Productive hours heatmap
                            productiveHoursSection(stats: stats)

                            // Streak section
                            streakSection(stats: stats)
                        } else {
                            emptyState
                        }
                    }
                    .padding(Spacing.lg)
                }
                .background(Color.backgroundPrimary)
                .navigationTitle("Statistics")
                .navigationBarTitleDisplayMode(.large)
                .refreshable {
                    store.send(.refreshStatistics)
                }
                .onAppear {
                    if store.statistics == nil {
                        store.send(.loadStatistics)
                    }
                }
            }
        }
    }

    private var periodSelector: some View {
        Picker("Period", selection: $store.selectedPeriod.sending(\.periodChanged)) {
            ForEach(StatisticsPeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    private func quickStatsSection(stats: PersonalStatistics) -> some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                StatCard(
                    title: "Total Focus",
                    value: String(format: "%.1fh", stats.totalFocusTime / 3600),
                    icon: "brain.head.profile",
                    color: .pomodoroRed
                )

                StatCard(
                    title: "Sessions",
                    value: "\(stats.completedSessions)",
                    icon: "checkmark.circle.fill",
                    color: .success
                )
            }

            HStack(spacing: Spacing.md) {
                StatCard(
                    title: "Current Streak",
                    value: "\(stats.currentStreak) days",
                    icon: "flame.fill",
                    color: .warning
                )

                StatCard(
                    title: "Longest Streak",
                    value: "\(stats.longestStreak) days",
                    icon: "star.fill",
                    color: .info
                )
            }
        }
    }

    private func dailyChartSection(stats: PersonalStatistics) -> some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("Daily Activity")
                    .font(.bodyHeadline)
                    .foregroundStyle(Color.labelPrimary)

                if stats.dailyStats.isEmpty {
                    Text("No data available")
                        .font(.bodyRegular)
                        .foregroundStyle(Color.labelSecondary)
                        .frame(maxWidth: .infinity, minHeight: 150)
                } else {
                    Chart {
                        ForEach(stats.dailyStats) { day in
                            BarMark(
                                x: .value("Date", day.date, unit: .day),
                                y: .value("Pomodoros", day.completedPomodoros)
                            )
                            .foregroundStyle(Color.pomodoroRed.gradient)
                            .cornerRadius(4)
                        }
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisGridLine()
                            AxisValueLabel()
                        }
                    }
                }
            }
        }
    }

    private func productiveHoursSection(stats: PersonalStatistics) -> some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("Productive Hours")
                    .font(.bodyHeadline)
                    .foregroundStyle(Color.labelPrimary)

                if stats.productiveHours.isEmpty {
                    Text("No data available")
                        .font(.bodyRegular)
                        .foregroundStyle(Color.labelSecondary)
                        .frame(maxWidth: .infinity, minHeight: 150)
                } else {
                    Chart {
                        ForEach(stats.productiveHours) { hour in
                            BarMark(
                                x: .value("Hour", hour.hour),
                                y: .value("Pomodoros", hour.completedPomodoros)
                            )
                            .foregroundStyle(
                                Color.breakGreen.gradient.opacity(
                                    intensityForValue(
                                        hour.completedPomodoros,
                                        max: stats.productiveHours.map(\.completedPomodoros).max() ?? 1
                                    )
                                )
                            )
                        }
                    }
                    .frame(height: 150)
                    .chartXAxis {
                        AxisMarks(values: Array(stride(from: 0, through: 23, by: 3))) { value in
                            AxisValueLabel {
                                if let hour = value.as(Int.self) {
                                    Text("\(hour):00")
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func streakSection(stats: PersonalStatistics) -> some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.title)
                        .foregroundStyle(Color.warning)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Keep Your Streak Going!")
                            .font(.bodyHeadline)
                            .foregroundStyle(Color.labelPrimary)

                        Text("You're on a \(stats.currentStreak) day streak")
                            .font(.captionPrimary)
                            .foregroundStyle(Color.labelSecondary)
                    }

                    Spacer()
                }

                if stats.currentStreak < stats.longestStreak {
                    Text("Your longest streak was \(stats.longestStreak) days")
                        .font(.captionPrimary)
                        .foregroundStyle(Color.labelTertiary)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "chart.bar")
                .font(.system(size: 64))
                .foregroundStyle(Color.labelTertiary)

            Text("No Statistics Yet")
                .font(.displayTitle3)
                .foregroundStyle(Color.labelPrimary)

            Text("Complete some Pomodoro sessions to see your statistics")
                .font(.bodyRegular)
                .foregroundStyle(Color.labelSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxxl)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }

    private func intensityForValue(_ value: Int, max: Int) -> Double {
        guard max > 0 else { return 0 }
        return Double(value) / Double(max) * 0.7 + 0.3
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                        .font(.title3)

                    Spacer()
                }

                Text(value)
                    .font(.displayTitle2)
                    .foregroundStyle(Color.labelPrimary)

                Text(title)
                    .font(.captionPrimary)
                    .foregroundStyle(Color.labelSecondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StatisticsView(
        store: Store(initialState: StatisticsFeature.State()) {
            StatisticsFeature()
        }
    )
}

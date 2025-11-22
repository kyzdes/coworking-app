import SwiftUI
import ComposableArchitecture

public struct TimerView: View {
    @Perception.Bindable var store: StoreOf<TimerFeature>

    public init(store: StoreOf<TimerFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ZStack {
                    // Background gradient
                    store.currentPhase.color.opacity(0.1)
                        .ignoresSafeArea()

                    ScrollView {
                        VStack(spacing: Spacing.xxxl) {
                            // Phase indicator
                            PhaseIndicator(phase: store.currentPhase)
                                .padding(.top, Spacing.xl)

                            // Circular timer
                            CircularTimer(
                                progress: store.progress,
                                timeRemaining: store.formattedTime,
                                color: store.currentPhase.color
                            )

                            // Controls
                            TimerControls(
                                isRunning: store.isRunning,
                                isPaused: store.isPaused,
                                onStart: { store.send(.startTimer) },
                                onPause: { store.send(.pauseTimer) },
                                onResume: { store.send(.resumeTimer) },
                                onStop: { store.send(.stopTimer) }
                            )

                            // Stats
                            StatsRow(completedPomodoros: store.completedPomodorosToday)

                            Spacer()
                        }
                        .padding(Spacing.xl)
                    }
                }
                .navigationTitle("Focus Timer")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // TODO: Navigate to settings
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(Color.labelPrimary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Phase Indicator

private struct PhaseIndicator: View {
    let phase: SessionPhase

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: phase.iconName)
                .font(.bodyHeadline)
                .foregroundStyle(phase.color)

            Text(phase.displayName)
                .font(.bodyHeadline)
                .foregroundStyle(Color.labelPrimary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Color.backgroundSecondary)
        .cornerRadius(CornerRadius.xl)
    }
}

// MARK: - Circular Timer

private struct CircularTimer: View {
    let progress: Double
    let timeRemaining: String
    let color: Color

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 20)
                .frame(width: 280, height: 280)

            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            // Time display
            Text(timeRemaining)
                .font(.timerDisplay)
                .foregroundStyle(Color.labelPrimary)
                .monospacedDigit()
        }
    }
}

// MARK: - Timer Controls

private struct TimerControls: View {
    let isRunning: Bool
    let isPaused: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onStop: () -> Void

    var body: some View {
        HStack(spacing: Spacing.lg) {
            if !isRunning {
                // Start button
                PrimaryButton("Start", icon: "play.fill", size: .large) {
                    onStart()
                }
            } else {
                // Pause/Resume button
                PrimaryButton(
                    isPaused ? "Resume" : "Pause",
                    icon: isPaused ? "play.fill" : "pause.fill",
                    style: .outlined,
                    size: .large
                ) {
                    if isPaused {
                        onResume()
                    } else {
                        onPause()
                    }
                }

                // Stop button
                PrimaryButton("Stop", icon: "stop.fill", size: .large) {
                    onStop()
                }
            }
        }
    }
}

// MARK: - Stats Row

private struct StatsRow: View {
    let completedPomodoros: Int

    var body: some View {
        Card {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Today's Focus")
                        .font(.captionPrimary)
                        .foregroundStyle(Color.labelSecondary)

                    Text("\(completedPomodoros)")
                        .font(.displayTitle2)
                        .foregroundStyle(Color.labelPrimary)
                }

                Spacer()

                Image(systemName: "flame.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.pomodoroRed)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TimerView(
        store: Store(initialState: TimerFeature.State()) {
            TimerFeature()
        }
    )
}

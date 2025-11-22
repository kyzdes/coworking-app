import XCTest
import ComposableArchitecture
@testable import Features

@MainActor
final class TimerFeatureTests: XCTestCase {
    func testTimerStart() async {
        let clock = TestClock()

        let store = TestStore(initialState: TimerFeature.State()) {
            TimerFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.startTimer) {
            $0.isRunning = true
            $0.isPaused = false
        }

        // Simulate time passing
        await clock.advance(by: .seconds(1))
        await store.receive(.timerTicked) {
            $0.timeRemaining = $0.totalDuration - 1
        }
    }

    func testTimerPause() async {
        let clock = TestClock()

        let store = TestStore(
            initialState: TimerFeature.State(
                timeRemaining: 1500,
                totalDuration: 1500
            )
        ) {
            TimerFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.startTimer) {
            $0.isRunning = true
            $0.isPaused = false
        }

        await store.send(.pauseTimer) {
            $0.isPaused = true
        }
    }

    func testTimerComplete() async {
        let store = TestStore(
            initialState: TimerFeature.State(
                timeRemaining: 0,
                totalDuration: 1500,
                currentPhase: .work
            )
        ) {
            TimerFeature()
        }

        await store.send(.completeSession) {
            $0.isRunning = false
            $0.isPaused = false
            $0.completedPomodoros = 1
            $0.completedPomodorosToday = 1
            $0.currentPhase = .shortBreak
            $0.totalDuration = $0.currentPhase.defaultDuration
            $0.timeRemaining = $0.totalDuration
        }
    }

    func testUpdateSettings() async {
        let newSettings = TimerSettings(
            workDuration: 30 * 60,
            shortBreakDuration: 10 * 60,
            longBreakDuration: 20 * 60,
            sessionsUntilLongBreak: 3,
            autoStartNextSession: true,
            autoStartBreaks: true
        )

        let store = TestStore(initialState: TimerFeature.State()) {
            TimerFeature()
        }

        await store.send(.updateSettings(newSettings)) {
            $0.settings = newSettings
            $0.totalDuration = newSettings.workDuration
            $0.timeRemaining = newSettings.workDuration
        }
    }
}

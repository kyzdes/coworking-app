import UIKit
import CoreHaptics
import Dependencies

/// Service for haptic feedback
public actor HapticService {
    private var engine: CHHapticEngine?
    private var supportsHaptics: Bool = false

    public init() {
        setupHapticEngine()
    }

    // MARK: - Setup

    private func setupHapticEngine() {
        // Check if device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            supportsHaptics = false
            return
        }

        supportsHaptics = true

        do {
            engine = try CHHapticEngine()
            try engine?.start()

            // Handle engine reset
            engine?.resetHandler = { [weak self] in
                Task { [weak self] in
                    await self?.restartEngine()
                }
            }

            // Handle engine stopped
            engine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason)")
            }
        } catch {
            print("Failed to create haptic engine: \(error)")
            supportsHaptics = false
        }
    }

    private func restartEngine() async {
        do {
            try engine?.start()
        } catch {
            print("Failed to restart haptic engine: \(error)")
        }
    }

    // MARK: - Simple Haptics

    /// Trigger a simple impact feedback
    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    /// Trigger a notification feedback
    public func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    /// Trigger a selection feedback
    public func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Custom Haptic Patterns

    /// Play haptic pattern for timer start
    public func timerStarted() async {
        guard supportsHaptics else {
            impact(.medium)
            return
        }

        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0.1
            )
        ]

        await playPattern(events: events)
    }

    /// Play haptic pattern for timer paused
    public func timerPaused() async {
        guard supportsHaptics else {
            impact(.light)
            return
        }

        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0
            )
        ]

        await playPattern(events: events)
    }

    /// Play haptic pattern for session complete
    public func sessionCompleted() async {
        guard supportsHaptics else {
            notification(.success)
            return
        }

        // Create a celebratory pattern
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0.1
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0.2
            )
        ]

        await playPattern(events: events)
    }

    /// Play haptic pattern for milestone achieved
    public func milestoneAchieved() async {
        guard supportsHaptics else {
            notification(.success)
            return
        }

        // Create an exciting pattern
        var events: [CHHapticEvent] = []
        for i in 0..<5 {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: TimeInterval(i) * 0.08
            )
            events.append(event)
        }

        await playPattern(events: events)
    }

    /// Play haptic pattern for error
    public func error() async {
        guard supportsHaptics else {
            notification(.error)
            return
        }

        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0.1
            )
        ]

        await playPattern(events: events)
    }

    /// Play haptic pattern for button tap
    public func buttonTap() {
        impact(.light)
    }

    /// Play haptic pattern for toggle
    public func toggle() {
        selection()
    }

    // MARK: - Private Methods

    private func playPattern(events: [CHHapticEvent]) async {
        guard supportsHaptics, let engine = engine else { return }

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
}

// MARK: - Dependency

extension HapticService: DependencyKey {
    public static let liveValue = HapticService()
    public static let testValue = HapticService()
}

extension DependencyValues {
    public var hapticService: HapticService {
        get { self[HapticService.self] }
        set { self[HapticService.self] = newValue }
    }
}

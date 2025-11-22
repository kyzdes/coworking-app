import EventKit
import Foundation
import Dependencies

/// Service for Calendar integration
public actor CalendarService {
    private let eventStore = EKEventStore()

    public init() {}

    // MARK: - Permissions

    /// Check calendar access status
    public func checkAuthorizationStatus() -> EKAuthorizationStatus {
        if #available(iOS 17.0, *) {
            return EKEventStore.authorizationStatus(for: .event)
        } else {
            return EKEventStore.authorizationStatus(for: .event)
        }
    }

    /// Request calendar access
    public func requestAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestFullAccessToEvents()
        } else {
            return try await eventStore.requestAccess(to: .event)
        }
    }

    // MARK: - Event Management

    /// Create a calendar event for a Pomodoro session
    public func createPomodoroEvent(
        title: String,
        startDate: Date,
        duration: TimeInterval,
        notes: String? = nil
    ) async throws {
        // Ensure we have permission
        let hasAccess: Bool
        if #available(iOS 17.0, *) {
            hasAccess = try await eventStore.requestFullAccessToEvents()
        } else {
            hasAccess = try await eventStore.requestAccess(to: .event)
        }

        guard hasAccess else {
            throw CalendarError.accessDenied
        }

        // Get or create Pomodoro calendar
        let calendar = try await getOrCreatePomodoroCalendar()

        // Create event
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = title
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(duration)
        event.notes = notes

        // Set availability to busy
        event.availability = .busy

        // Add alarm 5 minutes before
        let alarm = EKAlarm(relativeOffset: -300) // 5 minutes before
        event.addAlarm(alarm)

        // Save event
        try eventStore.save(event, span: .thisEvent)
    }

    /// Create recurring Pomodoro events
    public func createRecurringPomodoroEvents(
        title: String,
        startDate: Date,
        duration: TimeInterval,
        count: Int
    ) async throws {
        guard count > 0 else { return }

        // Ensure we have permission
        let hasAccess: Bool
        if #available(iOS 17.0, *) {
            hasAccess = try await eventStore.requestFullAccessToEvents()
        } else {
            hasAccess = try await eventStore.requestAccess(to: .event)
        }

        guard hasAccess else {
            throw CalendarError.accessDenied
        }

        let calendar = try await getOrCreatePomodoroCalendar()
        var currentStart = startDate

        for i in 0..<count {
            let event = EKEvent(eventStore: eventStore)
            event.calendar = calendar
            event.title = "\(title) (\(i + 1)/\(count))"
            event.startDate = currentStart
            event.endDate = currentStart.addingTimeInterval(duration)
            event.availability = .busy

            try eventStore.save(event, span: .thisEvent)

            // Move to next session (work + break)
            currentStart = currentStart.addingTimeInterval(duration + 300) // + 5 min break
        }
    }

    /// Delete all Pomodoro events for a specific date
    public func deletePomodoroEvents(for date: Date) async throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )

        let events = eventStore.events(matching: predicate)

        for event in events {
            if event.calendar?.title == "Pomodoro" {
                try eventStore.remove(event, span: .thisEvent)
            }
        }
    }

    /// Get upcoming Pomodoro events
    public func getUpcomingPomodoroEvents(limit: Int = 10) -> [EKEvent] {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!

        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil
        )

        let events = eventStore.events(matching: predicate)
        let pomodoroEvents = events.filter { $0.calendar?.title == "Pomodoro" }

        return Array(pomodoroEvents.prefix(limit))
    }

    // MARK: - Private Methods

    private func getOrCreatePomodoroCalendar() async throws -> EKCalendar {
        // Try to find existing Pomodoro calendar
        let calendars = eventStore.calendars(for: .event)
        if let existingCalendar = calendars.first(where: { $0.title == "Pomodoro" }) {
            return existingCalendar
        }

        // Create new calendar
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = "Pomodoro"
        newCalendar.cgColor = UIColor(red: 0.95, green: 0.26, blue: 0.21, alpha: 1.0).cgColor

        // Get default source
        if let source = eventStore.defaultCalendarForNewEvents?.source {
            newCalendar.source = source
        } else if let source = eventStore.sources.first(where: { $0.sourceType == .local }) {
            newCalendar.source = source
        } else {
            throw CalendarError.noCalendarSource
        }

        try eventStore.saveCalendar(newCalendar, commit: true)
        return newCalendar
    }
}

// MARK: - Calendar Error

public enum CalendarError: LocalizedError {
    case accessDenied
    case noCalendarSource
    case eventNotFound
    case saveFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Calendar access was denied. Please enable it in Settings."
        case .noCalendarSource:
            return "No calendar source available"
        case .eventNotFound:
            return "Calendar event not found"
        case .saveFailed(let error):
            return "Failed to save calendar event: \(error.localizedDescription)"
        }
    }
}

// MARK: - Dependency

extension CalendarService: DependencyKey {
    public static let liveValue = CalendarService()
    public static let testValue = CalendarService()
}

extension DependencyValues {
    public var calendarService: CalendarService {
        get { self[CalendarService.self] }
        set { self[CalendarService.self] = newValue }
    }
}

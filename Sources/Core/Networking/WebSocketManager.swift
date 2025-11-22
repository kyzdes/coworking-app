import Foundation
import Dependencies

/// WebSocket event types
public enum WebSocketEvent: Sendable {
    case connected
    case disconnected
    case message(WebSocketMessage)
    case error(Error)
}

/// WebSocket messages
public enum WebSocketMessage: Codable, Sendable {
    case timerStart(TimerStartMessage)
    case timerUpdate(TimerUpdateMessage)
    case timerComplete(TimerCompleteMessage)
    case presenceUpdate(PresenceUpdateMessage)
    case officeMemberStatusChanged(OfficeMemberStatusMessage)
    case officeMemberJoined(OfficeMemberJoinedMessage)
    case officeMemberLeft(OfficeMemberLeftMessage)

    enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    enum MessageType: String, Codable {
        case timerStart = "timer.start"
        case timerUpdate = "timer.update"
        case timerComplete = "timer.complete"
        case presenceUpdate = "presence.update"
        case officeMemberStatusChanged = "office.member_status_changed"
        case officeMemberJoined = "office.member_joined"
        case officeMemberLeft = "office.member_left"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)

        switch type {
        case .timerStart:
            let data = try container.decode(TimerStartMessage.self, forKey: .data)
            self = .timerStart(data)
        case .timerUpdate:
            let data = try container.decode(TimerUpdateMessage.self, forKey: .data)
            self = .timerUpdate(data)
        case .timerComplete:
            let data = try container.decode(TimerCompleteMessage.self, forKey: .data)
            self = .timerComplete(data)
        case .presenceUpdate:
            let data = try container.decode(PresenceUpdateMessage.self, forKey: .data)
            self = .presenceUpdate(data)
        case .officeMemberStatusChanged:
            let data = try container.decode(OfficeMemberStatusMessage.self, forKey: .data)
            self = .officeMemberStatusChanged(data)
        case .officeMemberJoined:
            let data = try container.decode(OfficeMemberJoinedMessage.self, forKey: .data)
            self = .officeMemberJoined(data)
        case .officeMemberLeft:
            let data = try container.decode(OfficeMemberLeftMessage.self, forKey: .data)
            self = .officeMemberLeft(data)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .timerStart(let data):
            try container.encode(MessageType.timerStart, forKey: .type)
            try container.encode(data, forKey: .data)
        case .timerUpdate(let data):
            try container.encode(MessageType.timerUpdate, forKey: .type)
            try container.encode(data, forKey: .data)
        case .timerComplete(let data):
            try container.encode(MessageType.timerComplete, forKey: .type)
            try container.encode(data, forKey: .data)
        case .presenceUpdate(let data):
            try container.encode(MessageType.presenceUpdate, forKey: .type)
            try container.encode(data, forKey: .data)
        case .officeMemberStatusChanged(let data):
            try container.encode(MessageType.officeMemberStatusChanged, forKey: .type)
            try container.encode(data, forKey: .data)
        case .officeMemberJoined(let data):
            try container.encode(MessageType.officeMemberJoined, forKey: .type)
            try container.encode(data, forKey: .data)
        case .officeMemberLeft(let data):
            try container.encode(MessageType.officeMemberLeft, forKey: .type)
            try container.encode(data, forKey: .data)
        }
    }
}

// MARK: - Message Types

public struct TimerStartMessage: Codable, Sendable {
    public let sessionId: UUID
    public let duration: TimeInterval
    public let phase: SessionPhase

    public init(sessionId: UUID, duration: TimeInterval, phase: SessionPhase) {
        self.sessionId = sessionId
        self.duration = duration
        self.phase = phase
    }
}

public struct TimerUpdateMessage: Codable, Sendable {
    public let sessionId: UUID
    public let timeRemaining: TimeInterval

    public init(sessionId: UUID, timeRemaining: TimeInterval) {
        self.sessionId = sessionId
        self.timeRemaining = timeRemaining
    }
}

public struct TimerCompleteMessage: Codable, Sendable {
    public let sessionId: UUID

    public init(sessionId: UUID) {
        self.sessionId = sessionId
    }
}

public struct PresenceUpdateMessage: Codable, Sendable {
    public let status: UserStatus

    public init(status: UserStatus) {
        self.status = status
    }
}

public struct OfficeMemberStatusMessage: Codable, Sendable {
    public let officeId: UUID
    public let userId: UUID
    public let status: UserStatus
    public let timeRemaining: TimeInterval?

    public init(officeId: UUID, userId: UUID, status: UserStatus, timeRemaining: TimeInterval?) {
        self.officeId = officeId
        self.userId = userId
        self.status = status
        self.timeRemaining = timeRemaining
    }
}

public struct OfficeMemberJoinedMessage: Codable, Sendable {
    public let officeId: UUID
    public let userId: UUID
    public let username: String

    public init(officeId: UUID, userId: UUID, username: String) {
        self.officeId = officeId
        self.userId = userId
        self.username = username
    }
}

public struct OfficeMemberLeftMessage: Codable, Sendable {
    public let officeId: UUID
    public let userId: UUID

    public init(officeId: UUID, userId: UUID) {
        self.officeId = officeId
        self.userId = userId
    }
}

// MARK: - WebSocket Manager

public actor WebSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url: URL
    private let session: URLSession
    private var isConnected = false
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private let decoder = JSONDecoder.default
    private let encoder = JSONEncoder.default

    public init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }

    /// Connect to the WebSocket server
    public func connect() async throws {
        guard !isConnected else { return }

        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        reconnectAttempts = 0

        // Start listening for messages
        Task {
            await receiveMessages()
        }
    }

    /// Disconnect from the WebSocket server
    public func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }

    /// Send a message to the server
    public func send(_ message: WebSocketMessage) async throws {
        guard isConnected else {
            throw NetworkError.networkUnavailable
        }

        let data = try encoder.encode(message)
        let urlSessionMessage = URLSessionWebSocketTask.Message.data(data)

        try await webSocketTask?.send(urlSessionMessage)
    }

    /// Receive messages from the server
    private func receiveMessages() async {
        guard let task = webSocketTask else { return }

        do {
            let message = try await task.receive()

            switch message {
            case .data(let data):
                if let decodedMessage = try? decoder.decode(WebSocketMessage.self, from: data) {
                    // Handle message (will be implemented in feature modules)
                    await handleMessage(decodedMessage)
                }
            case .string(let text):
                if let data = text.data(using: .utf8),
                   let decodedMessage = try? decoder.decode(WebSocketMessage.self, from: data) {
                    await handleMessage(decodedMessage)
                }
            @unknown default:
                break
            }

            // Continue receiving messages
            await receiveMessages()
        } catch {
            // Connection closed or error occurred
            isConnected = false
            await attemptReconnect()
        }
    }

    /// Attempt to reconnect with exponential backoff
    private func attemptReconnect() async {
        guard reconnectAttempts < maxReconnectAttempts else {
            return
        }

        reconnectAttempts += 1
        let delay = TimeInterval(pow(2.0, Double(reconnectAttempts)))

        try? await Task.sleep(for: .seconds(delay))

        do {
            try await connect()
        } catch {
            await attemptReconnect()
        }
    }

    /// Handle incoming message (to be implemented by features)
    private func handleMessage(_ message: WebSocketMessage) async {
        // This will be implemented by injecting a handler via dependency injection
    }
}

// MARK: - Dependency

extension WebSocketManager: DependencyKey {
    public static let liveValue: WebSocketManager = {
        // TODO: Replace with actual WebSocket URL
        let url = URL(string: "wss://api.virtualoffice.app/ws")!
        return WebSocketManager(url: url)
    }()

    public static let testValue: WebSocketManager = {
        let url = URL(string: "wss://test.api.virtualoffice.app/ws")!
        return WebSocketManager(url: url)
    }()
}

extension DependencyValues {
    public var webSocketManager: WebSocketManager {
        get { self[WebSocketManager.self] }
        set { self[WebSocketManager.self] = newValue }
    }
}

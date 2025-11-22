import Foundation

/// Represents an API endpoint
public struct Endpoint: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]?
    public let headers: [String: String]?
    public let body: Data?

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }

    /// Create a URL request from the endpoint
    public func makeRequest(baseURL: URL) throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
}

// MARK: - HTTP Method
public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Endpoints
public extension Endpoint {
    // MARK: - Authentication
    static func register(email: String, password: String, username: String) -> Endpoint {
        let body = try? JSONEncoder().encode([
            "email": email,
            "password": password,
            "username": username
        ])
        return Endpoint(path: "/auth/register", method: .post, body: body)
    }

    static func login(email: String, password: String) -> Endpoint {
        let body = try? JSONEncoder().encode([
            "email": email,
            "password": password
        ])
        return Endpoint(path: "/auth/login", method: .post, body: body)
    }

    static func loginWithApple(identityToken: String, authorizationCode: String) -> Endpoint {
        let body = try? JSONEncoder().encode([
            "identityToken": identityToken,
            "authorizationCode": authorizationCode
        ])
        return Endpoint(path: "/auth/apple", method: .post, body: body)
    }

    static func refreshToken(refreshToken: String) -> Endpoint {
        let body = try? JSONEncoder().encode(["refreshToken": refreshToken])
        return Endpoint(path: "/auth/refresh", method: .post, body: body)
    }

    // MARK: - Users
    static func getCurrentUser() -> Endpoint {
        Endpoint(path: "/users/me", method: .get)
    }

    static func updateUser(updates: [String: Any]) -> Endpoint {
        let body = try? JSONSerialization.data(withJSONObject: updates)
        return Endpoint(path: "/users/me", method: .patch, body: body)
    }

    static func getUser(id: UUID) -> Endpoint {
        Endpoint(path: "/users/\(id.uuidString)", method: .get)
    }

    static func searchUsers(query: String) -> Endpoint {
        let queryItems = [URLQueryItem(name: "q", value: query)]
        return Endpoint(path: "/users/search", method: .get, queryItems: queryItems)
    }

    // MARK: - Friends
    static func getFriends() -> Endpoint {
        Endpoint(path: "/friends", method: .get)
    }

    static func inviteFriend(userId: UUID) -> Endpoint {
        let body = try? JSONEncoder().encode(["userId": userId.uuidString])
        return Endpoint(path: "/friends/invite", method: .post, body: body)
    }

    static func acceptFriend(friendshipId: UUID) -> Endpoint {
        Endpoint(path: "/friends/accept/\(friendshipId.uuidString)", method: .post)
    }

    static func removeFriend(friendId: UUID) -> Endpoint {
        Endpoint(path: "/friends/\(friendId.uuidString)", method: .delete)
    }

    // MARK: - Offices
    static func getOffices() -> Endpoint {
        Endpoint(path: "/offices", method: .get)
    }

    static func createOffice(name: String, description: String) -> Endpoint {
        let body = try? JSONEncoder().encode([
            "name": name,
            "description": description
        ])
        return Endpoint(path: "/offices", method: .post, body: body)
    }

    static func getOffice(id: UUID) -> Endpoint {
        Endpoint(path: "/offices/\(id.uuidString)", method: .get)
    }

    static func updateOffice(id: UUID, updates: [String: Any]) -> Endpoint {
        let body = try? JSONSerialization.data(withJSONObject: updates)
        return Endpoint(path: "/offices/\(id.uuidString)", method: .patch, body: body)
    }

    static func deleteOffice(id: UUID) -> Endpoint {
        Endpoint(path: "/offices/\(id.uuidString)", method: .delete)
    }

    static func addOfficeMember(officeId: UUID, userId: UUID) -> Endpoint {
        let body = try? JSONEncoder().encode(["userId": userId.uuidString])
        return Endpoint(path: "/offices/\(officeId.uuidString)/members", method: .post, body: body)
    }

    static func removeOfficeMember(officeId: UUID, userId: UUID) -> Endpoint {
        Endpoint(path: "/offices/\(officeId.uuidString)/members/\(userId.uuidString)", method: .delete)
    }

    // MARK: - Sessions
    static func getSessions() -> Endpoint {
        Endpoint(path: "/sessions", method: .get)
    }

    static func createSession(phase: SessionPhase, duration: TimeInterval, officeId: UUID?) -> Endpoint {
        var dict: [String: Any] = [
            "phase": phase.rawValue,
            "duration": duration
        ]
        if let officeId = officeId {
            dict["officeId"] = officeId.uuidString
        }
        let body = try? JSONSerialization.data(withJSONObject: dict)
        return Endpoint(path: "/sessions", method: .post, body: body)
    }

    static func updateSession(id: UUID, updates: [String: Any]) -> Endpoint {
        let body = try? JSONSerialization.data(withJSONObject: updates)
        return Endpoint(path: "/sessions/\(id.uuidString)", method: .patch, body: body)
    }

    // MARK: - Statistics
    static func getPersonalStats() -> Endpoint {
        Endpoint(path: "/stats/personal", method: .get)
    }

    static func getOfficeStats(officeId: UUID) -> Endpoint {
        Endpoint(path: "/stats/office/\(officeId.uuidString)", method: .get)
    }
}

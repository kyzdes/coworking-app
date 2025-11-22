import Foundation
import AuthenticationServices
import Dependencies

/// Authentication manager handling user authentication and token management
public actor AuthManager {
    private let networkService: NetworkService
    private let keychainService: KeychainService

    private var currentUser: User?
    private var accessToken: String?
    private var refreshToken: String?

    public init(
        networkService: NetworkService,
        keychainService: KeychainService
    ) {
        self.networkService = networkService
        self.keychainService = keychainService
    }

    // MARK: - Public Methods

    /// Check if user is authenticated
    public var isAuthenticated: Bool {
        accessToken != nil
    }

    /// Get current user
    public func getCurrentUser() -> User? {
        currentUser
    }

    /// Register with email and password
    public func register(email: String, password: String, username: String) async throws -> User {
        let endpoint = Endpoint.register(email: email, password: password, username: username)
        let response: AuthResponse = try await networkService.request(endpoint, type: AuthResponse.self)

        try await saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )

        self.currentUser = response.user
        return response.user
    }

    /// Login with email and password
    public func login(email: String, password: String) async throws -> User {
        let endpoint = Endpoint.login(email: email, password: password)
        let response: AuthResponse = try await networkService.request(endpoint, type: AuthResponse.self)

        try await saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )

        self.currentUser = response.user
        return response.user
    }

    /// Login with Apple
    public func loginWithApple(authorization: ASAuthorization) async throws -> User {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let authorizationCode = appleIDCredential.authorizationCode,
              let identityTokenString = String(data: identityToken, encoding: .utf8),
              let authorizationCodeString = String(data: authorizationCode, encoding: .utf8) else {
            throw AuthError.invalidCredentials
        }

        let endpoint = Endpoint.loginWithApple(
            identityToken: identityTokenString,
            authorizationCode: authorizationCodeString
        )
        let response: AuthResponse = try await networkService.request(endpoint, type: AuthResponse.self)

        try await saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )

        // Save Apple User ID for future logins
        try await keychainService.save(appleIDCredential.user, for: KeychainKey.appleUserId)

        self.currentUser = response.user
        return response.user
    }

    /// Refresh access token
    public func refreshAccessToken() async throws {
        guard let refreshToken = refreshToken else {
            throw AuthError.notAuthenticated
        }

        let endpoint = Endpoint.refreshToken(refreshToken: refreshToken)
        let response: TokenResponse = try await networkService.request(endpoint, type: TokenResponse.self)

        try await saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
    }

    /// Logout
    public func logout() async throws {
        // Clear tokens
        try await keychainService.delete(for: KeychainKey.accessToken)
        try await keychainService.delete(for: KeychainKey.refreshToken)
        try await keychainService.delete(for: KeychainKey.userId)

        self.accessToken = nil
        self.refreshToken = nil
        self.currentUser = nil
    }

    /// Restore session from Keychain
    public func restoreSession() async throws {
        do {
            let accessToken = try await keychainService.retrieveString(for: KeychainKey.accessToken)
            let refreshToken = try await keychainService.retrieveString(for: KeychainKey.refreshToken)

            self.accessToken = accessToken
            self.refreshToken = refreshToken

            // Fetch current user
            let endpoint = Endpoint.getCurrentUser()
            let user: User = try await networkService.request(endpoint, type: User.self)
            self.currentUser = user
        } catch {
            throw AuthError.sessionExpired
        }
    }

    /// Get access token for API requests
    public func getAccessToken() async throws -> String {
        guard let token = accessToken else {
            throw AuthError.notAuthenticated
        }
        return token
    }

    // MARK: - Private Methods

    private func saveTokens(accessToken: String, refreshToken: String) async throws {
        try await keychainService.save(accessToken, for: KeychainKey.accessToken)
        try await keychainService.save(refreshToken, for: KeychainKey.refreshToken)

        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

// MARK: - Auth Response Models

public struct AuthResponse: Codable, Sendable {
    public let user: User
    public let accessToken: String
    public let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

public struct TokenResponse: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

// MARK: - Auth Error

public enum AuthError: LocalizedError {
    case notAuthenticated
    case sessionExpired
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists

    public var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You are not authenticated. Please sign in."
        case .sessionExpired:
            return "Your session has expired. Please sign in again."
        case .invalidCredentials:
            return "Invalid credentials. Please try again."
        case .userNotFound:
            return "User not found."
        case .emailAlreadyExists:
            return "An account with this email already exists."
        }
    }
}

// MARK: - Dependency

extension AuthManager: DependencyKey {
    public static let liveValue: AuthManager = {
        @Dependency(\.networkService) var networkService
        @Dependency(\.keychainService) var keychainService
        return AuthManager(
            networkService: networkService,
            keychainService: keychainService
        )
    }()

    public static let testValue: AuthManager = {
        return AuthManager(
            networkService: .testValue,
            keychainService: .testValue
        )
    }()
}

extension DependencyValues {
    public var authManager: AuthManager {
        get { self[AuthManager.self] }
        set { self[AuthManager.self] = newValue }
    }
}

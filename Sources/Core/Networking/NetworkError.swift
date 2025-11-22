import Foundation

/// Network-related errors
public enum NetworkError: LocalizedError, Sendable {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case unauthorized
    case forbidden
    case notFound
    case networkUnavailable
    case timeout
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .serverError(let statusCode, let message):
            return message ?? "Server error (code: \(statusCode))"
        case .unauthorized:
            return "Please sign in again"
        case .forbidden:
            return "You don't have permission to perform this action"
        case .notFound:
            return "Resource not found"
        case .networkUnavailable:
            return "Check your internet connection"
        case .timeout:
            return "Request timed out"
        case .unknown(let error):
            return "An error occurred: \(error.localizedDescription)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Make sure you're connected to the internet and try again"
        case .unauthorized:
            return "Sign in with your credentials"
        case .timeout:
            return "Please try again"
        default:
            return nil
        }
    }
}

// MARK: - Error Response
public struct ErrorResponse: Codable, Sendable {
    public let message: String
    public let code: String?
    public let details: [String: String]?

    public init(message: String, code: String? = nil, details: [String: String]? = nil) {
        self.message = message
        self.code = code
        self.details = details
    }
}

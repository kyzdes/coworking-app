import Foundation
import Dependencies

/// Protocol for network service
public protocol NetworkServiceProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint, type: T.Type) async throws -> T
    func request(_ endpoint: Endpoint) async throws
}

/// Network service implementation
public actor NetworkService: NetworkServiceProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = .default,
        encoder: JSONEncoder = .default
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    /// Make a network request and decode the response
    public func request<T: Decodable>(_ endpoint: Endpoint, type: T.Type) async throws -> T {
        let request = try endpoint.makeRequest(baseURL: baseURL)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "NetworkService", code: -1))
        }

        try validateResponse(httpResponse, data: data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    /// Make a network request without expecting a response body
    public func request(_ endpoint: Endpoint) async throws {
        let request = try endpoint.makeRequest(baseURL: baseURL)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "NetworkService", code: -1))
        }

        try validateResponse(httpResponse, data: data)
    }

    // MARK: - Private Methods

    private func validateResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            // Success
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 400...499:
            let errorMessage = try? decoder.decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(
                statusCode: response.statusCode,
                message: errorMessage?.message
            )
        case 500...599:
            let errorMessage = try? decoder.decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(
                statusCode: response.statusCode,
                message: errorMessage?.message
            )
        default:
            throw NetworkError.serverError(statusCode: response.statusCode, message: nil)
        }
    }
}

// MARK: - Dependency

extension NetworkService: DependencyKey {
    public static let liveValue: NetworkService = {
        // TODO: Replace with actual backend URL
        let baseURL = URL(string: "https://api.virtualoffice.app")!
        return NetworkService(baseURL: baseURL)
    }()

    public static let testValue: NetworkService = {
        let baseURL = URL(string: "https://test.api.virtualoffice.app")!
        return NetworkService(baseURL: baseURL)
    }()
}

extension DependencyValues {
    public var networkService: NetworkService {
        get { self[NetworkService.self] }
        set { self[NetworkService.self] = newValue }
    }
}

// MARK: - JSONDecoder + JSONEncoder Extensions

extension JSONDecoder {
    public static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

extension JSONEncoder {
    public static let `default`: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}

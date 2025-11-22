import Foundation
import ComposableArchitecture
import AuthenticationServices

@Reducer
public struct AuthenticationFeature {
    @ObservableState
    public struct State: Equatable {
        public var email: String = ""
        public var password: String = ""
        public var username: String = ""
        public var isLoading: Bool = false
        public var error: String?
        public var isSignUp: Bool = false
        public var isAuthenticated: Bool = false

        public init() {}
    }

    public enum Action: Equatable {
        case emailChanged(String)
        case passwordChanged(String)
        case usernameChanged(String)
        case toggleAuthMode
        case loginButtonTapped
        case signUpButtonTapped
        case appleSignInButtonTapped
        case appleSignInCompleted(Result<ASAuthorization, Error>)
        case loginResponse(Result<User, Error>)
        case signUpResponse(Result<User, Error>)
        case dismissError
        case restoreSession

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.emailChanged(let l), .emailChanged(let r)): return l == r
            case (.passwordChanged(let l), .passwordChanged(let r)): return l == r
            case (.usernameChanged(let l), .usernameChanged(let r)): return l == r
            case (.toggleAuthMode, .toggleAuthMode): return true
            case (.loginButtonTapped, .loginButtonTapped): return true
            case (.signUpButtonTapped, .signUpButtonTapped): return true
            case (.appleSignInButtonTapped, .appleSignInButtonTapped): return true
            case (.dismissError, .dismissError): return true
            case (.restoreSession, .restoreSession): return true
            case (.loginResponse(.success(let l)), .loginResponse(.success(let r))): return l == r
            case (.signUpResponse(.success(let l)), .signUpResponse(.success(let r))): return l == r
            case (.loginResponse(.failure), .loginResponse(.failure)): return true
            case (.signUpResponse(.failure), .signUpResponse(.failure)): return true
            case (.appleSignInCompleted(.success), .appleSignInCompleted(.success)): return true
            case (.appleSignInCompleted(.failure), .appleSignInCompleted(.failure)): return true
            default: return false
            }
        }
    }

    @Dependency(\.authManager) var authManager

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .emailChanged(let email):
                state.email = email
                state.error = nil
                return .none

            case .passwordChanged(let password):
                state.password = password
                state.error = nil
                return .none

            case .usernameChanged(let username):
                state.username = username
                state.error = nil
                return .none

            case .toggleAuthMode:
                state.isSignUp.toggle()
                state.error = nil
                return .none

            case .loginButtonTapped:
                guard !state.email.isEmpty, !state.password.isEmpty else {
                    state.error = "Please fill in all fields"
                    return .none
                }

                state.isLoading = true
                state.error = nil

                return .run { [email = state.email, password = state.password] send in
                    await send(.loginResponse(
                        Result {
                            try await authManager.login(email: email, password: password)
                        }
                    ))
                }

            case .signUpButtonTapped:
                guard !state.email.isEmpty, !state.password.isEmpty, !state.username.isEmpty else {
                    state.error = "Please fill in all fields"
                    return .none
                }

                state.isLoading = true
                state.error = nil

                return .run { [email = state.email, password = state.password, username = state.username] send in
                    await send(.signUpResponse(
                        Result {
                            try await authManager.register(
                                email: email,
                                password: password,
                                username: username
                            )
                        }
                    ))
                }

            case .appleSignInButtonTapped:
                state.isLoading = true
                state.error = nil
                // Apple Sign In will be handled by the view
                return .none

            case .appleSignInCompleted(.success(let authorization)):
                return .run { send in
                    await send(.loginResponse(
                        Result {
                            try await authManager.loginWithApple(authorization: authorization)
                        }
                    ))
                }

            case .appleSignInCompleted(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none

            case .loginResponse(.success):
                state.isLoading = false
                state.isAuthenticated = true
                return .none

            case .loginResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none

            case .signUpResponse(.success):
                state.isLoading = false
                state.isAuthenticated = true
                return .none

            case .signUpResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none

            case .dismissError:
                state.error = nil
                return .none

            case .restoreSession:
                return .run { send in
                    await send(.loginResponse(
                        Result {
                            try await authManager.restoreSession()
                            return try await authManager.getCurrentUser() ?? {
                                throw AuthError.notAuthenticated
                            }()
                        }
                    ))
                }
            }
        }
    }
}

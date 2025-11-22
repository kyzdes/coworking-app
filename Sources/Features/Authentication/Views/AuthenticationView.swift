import SwiftUI
import ComposableArchitecture
import AuthenticationServices

public struct AuthenticationView: View {
    @Perception.Bindable var store: StoreOf<AuthenticationFeature>

    public init(store: StoreOf<AuthenticationFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Logo and title
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "timer")
                                .font(.system(size: 64))
                                .foregroundStyle(Color.pomodoroRed)

                            Text("Virtual Office")
                                .font(.displayTitle)
                                .foregroundStyle(Color.labelPrimary)

                            Text("Pomodoro with Friends")
                                .font(.bodyCallout)
                                .foregroundStyle(Color.labelSecondary)
                        }
                        .padding(.top, Spacing.xxxl)

                        // Sign in with Apple
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                store.send(.appleSignInCompleted(result))
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: ButtonSize.lg)
                        .cornerRadius(CornerRadius.md)

                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.labelQuaternary)
                                .frame(height: 1)

                            Text("or")
                                .font(.captionPrimary)
                                .foregroundStyle(Color.labelTertiary)
                                .padding(.horizontal, Spacing.sm)

                            Rectangle()
                                .fill(Color.labelQuaternary)
                                .frame(height: 1)
                        }

                        // Email/Password form
                        VStack(spacing: Spacing.lg) {
                            if store.isSignUp {
                                TextField("Username", text: $store.username)
                                    .textFieldStyle(RoundedTextFieldStyle())
                                    .textContentType(.username)
                                    .autocapitalization(.none)
                            }

                            TextField("Email", text: $store.email)
                                .textFieldStyle(RoundedTextFieldStyle())
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)

                            SecureField("Password", text: $store.password)
                                .textFieldStyle(RoundedTextFieldStyle())
                                .textContentType(store.isSignUp ? .newPassword : .password)
                        }

                        // Error message
                        if let error = store.error {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(Color.error)

                                Text(error)
                                    .font(.captionPrimary)
                                    .foregroundStyle(Color.error)

                                Spacer()

                                Button {
                                    store.send(.dismissError)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color.labelTertiary)
                                }
                            }
                            .padding(Spacing.md)
                            .background(Color.error.opacity(0.1))
                            .cornerRadius(CornerRadius.md)
                        }

                        // Action button
                        PrimaryButton(
                            store.isSignUp ? "Sign Up" : "Sign In",
                            isLoading: store.isLoading
                        ) {
                            if store.isSignUp {
                                store.send(.signUpButtonTapped)
                            } else {
                                store.send(.loginButtonTapped)
                            }
                        }

                        // Toggle auth mode
                        Button {
                            store.send(.toggleAuthMode)
                        } label: {
                            Text(store.isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(.bodyCallout)
                                .foregroundStyle(Color.primaryAccent)
                        }
                    }
                    .padding(Spacing.xl)
                }
                .background(Color.backgroundPrimary)
            }
        }
    }
}

// MARK: - Text Field Style

private struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.bodyRegular)
            .padding(Spacing.lg)
            .background(Color.backgroundSecondary)
            .cornerRadius(CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(Color.labelQuaternary, lineWidth: 1)
            )
    }
}

// MARK: - Preview

#Preview {
    AuthenticationView(
        store: Store(initialState: AuthenticationFeature.State()) {
            AuthenticationFeature()
        }
    )
}

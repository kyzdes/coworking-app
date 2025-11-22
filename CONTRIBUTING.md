# Contributing to Virtual Office Pomodoro

First off, thank you for considering contributing to Virtual Office Pomodoro! It's people like you that make this project better for everyone.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps which reproduce the problem**
* **Provide specific examples to demonstrate the steps**
* **Describe the behavior you observed after following the steps**
* **Explain which behavior you expected to see instead and why**
* **Include screenshots and animated GIFs** if possible
* **Include your iOS version and device model**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a step-by-step description of the suggested enhancement**
* **Provide specific examples to demonstrate the steps**
* **Describe the current behavior** and **explain which behavior you expected to see instead**
* **Explain why this enhancement would be useful**

### Pull Requests

* Fill in the required template
* Do not include issue numbers in the PR title
* Follow the Swift style guide (SwiftLint configuration included)
* Include thoughtfully-worded, well-structured tests
* Document new code based on the Documentation Style Guide
* End all files with a newline

## Development Process

### 1. Fork and Clone

```bash
git fork https://github.com/yourusername/virtual-office-pomodoro.git
git clone https://github.com/yourusername/virtual-office-pomodoro.git
cd virtual-office-pomodoro
```

### 2. Create a Branch

```bash
git checkout -b feature/amazing-feature
```

### 3. Make Your Changes

* Write clean, readable code
* Follow The Composable Architecture patterns
* Add tests for new features
* Update documentation as needed

### 4. Test Your Changes

```bash
swift test
```

Run the app in Xcode and test manually:
* Test on both iPhone and iPad
* Test in both Light and Dark mode
* Test with Dynamic Type (accessibility)
* Test offline functionality

### 5. Commit Your Changes

We follow conventional commits:

```bash
git commit -m "feat: add amazing feature"
git commit -m "fix: resolve timer bug"
git commit -m "docs: update README"
```

Types:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that don't affect code meaning (formatting, etc)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests
- `chore`: Changes to build process or auxiliary tools

### 6. Push to Your Fork

```bash
git push origin feature/amazing-feature
```

### 7. Open a Pull Request

* Use a clear and descriptive title
* Reference any related issues
* Provide a comprehensive description of changes
* Include screenshots for UI changes

## Coding Standards

### Swift Style Guide

* Use Swift 6.0 features and strict concurrency
* Follow Apple's API Design Guidelines
* Use meaningful variable and function names
* Keep functions small and focused
* Use extensions to organize code
* Prefer `let` over `var` when possible
* Use `guard` for early returns
* Use trailing closures when appropriate

### TCA Patterns

* Keep reducers pure and testable
* Use dependencies for side effects
* Scope child features properly
* Write comprehensive tests for reducers

### SwiftUI Best Practices

* Use `@Perception.Bindable` with TCA stores
* Wrap views in `WithPerceptionTracking`
* Extract complex views into separate components
* Use `@ViewBuilder` for conditional content
* Prefer composition over inheritance

### Example

```swift
@Reducer
public struct MyFeature {
    @ObservableState
    public struct State: Equatable {
        var count: Int = 0
    }

    public enum Action: Equatable {
        case incrementButtonTapped
        case decrementButtonTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .incrementButtonTapped:
                state.count += 1
                return .none

            case .decrementButtonTapped:
                state.count -= 1
                return .none
            }
        }
    }
}
```

## Testing

* Write unit tests for all reducers
* Write integration tests for complex flows
* Aim for 80%+ code coverage
* Test edge cases and error scenarios
* Use `TestStore` for TCA features

## Documentation

* Document public APIs with Swift documentation comments
* Update README for new features
* Include code examples in documentation
* Keep inline comments minimal and focused on "why" not "what"

## Project Structure

Follow the existing structure:

```
Sources/
├── App/              # Main app and root feature
├── Core/             # Shared models, networking, auth
├── Features/         # Feature modules (TCA)
├── DesignSystem/     # Reusable UI components
└── Services/         # System services
```

## Questions?

Feel free to open an issue with your question or reach out to the maintainers.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

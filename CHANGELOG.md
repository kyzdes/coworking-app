# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure with Swift Package Manager
- Core data models using SwiftData (User, Office, PomodoroSession, Friendship)
- Networking layer with REST API and WebSocket support
- Authentication system with Sign in with Apple and Email/Password
- Keychain integration for secure token storage
- Pomodoro timer feature with TCA
  - Work sessions (25 minutes default)
  - Short breaks (5 minutes)
  - Long breaks (15 minutes)
  - Customizable timer settings
  - Real-time WebSocket updates
- Virtual office management
  - Create and manage offices
  - Real-time member status updates
  - Office member grid view
  - Maximum 20 members per office
- Design System
  - Custom color palette supporting Light/Dark mode
  - Typography system with Dynamic Type support
  - Consistent spacing and layout system
  - Reusable components (Buttons, Cards, Avatars)
- Main app navigation with TabView
- Authentication flow
- README and documentation
- Contributing guidelines
- MIT License
- SwiftLint configuration

### Coming Soon (Phase 1 MVP)
- Friends management feature
- Push and local notifications
- Notification service
- Haptic feedback integration
- Basic statistics and analytics

### Planned (Phase 2)
- Live Activities for Lock Screen
- Home Screen Widgets
- Advanced statistics with Charts framework
- QR code invitations
- Calendar integration
- Siri Shortcuts support

### Planned (Phase 3)
- Apple Watch companion app
- CloudKit synchronization
- Focus Mode integration
- Data export functionality

## [0.1.0] - 2025-01-XX

### Added
- Initial development version
- Project scaffolding
- Basic architecture setup

---

## Version History

- **Unreleased** - Current development version
- **0.1.0** - Initial development setup

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

### Added (Phase 2)
- Live Activities integration
  - Lock Screen display with timer countdown
  - Dynamic Island support (compact, minimal, expanded views)
  - Real-time progress updates
  - Phase transitions visualization
- Home Screen Widgets (WidgetKit)
  - Small widget: Current timer and pomodoros count
  - Medium widget: Timer + daily statistics
  - Large widget: Full session info + office details
  - App Group shared data for widget updates
- Advanced Statistics with Charts framework
  - Daily activity bar charts
  - Weekly progress tracking
  - Productive hours heatmap
  - Streak tracking and visualization
  - Personal statistics dashboard
- Friends Management Feature
  - Search and add friends
  - Friend requests (send, accept, decline)
  - Friends list with online status
  - QR code generation for quick add
  - QR code scanner with camera integration
  - Friend profile viewing
- Calendar Integration (EventKit)
  - Create calendar events for Pomodoro sessions
  - Recurring session scheduling
  - "Pomodoro" calendar auto-creation
  - Event deletion and management
  - Calendar permission handling
- Siri Shortcuts (App Intents)
  - "Start Pomodoro" intent with duration parameter
  - "Stop Pomodoro" intent
  - "Check Progress" intent with spoken feedback
  - Custom phrases support
  - Deep linking to app features
- Notification Service (UserNotifications)
  - Session complete notifications
  - Break reminders
  - Work session start reminders
  - Daily motivation notifications
  - Streak reminders
  - Friend activity notifications
  - Notification categories with actions
- Haptic Feedback Service (CoreHaptics)
  - Custom haptic patterns for timer events
  - Session start/pause/complete patterns
  - Milestone achievement celebrations
  - Error haptics
  - Button tap feedback
- Additional Services
  - WidgetDataService for widget synchronization
  - QRCodeService for QR generation/scanning
  - LiveActivityManager for activity lifecycle
  - Enhanced error handling across all services

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

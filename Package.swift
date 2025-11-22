// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VirtualOfficePomodoro",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .watchOS(.v11),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "VirtualOfficePomodoro",
            targets: ["App"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.15.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "1.4.0"
        )
    ],
    targets: [
        // MARK: - App
        .target(
            name: "App",
            dependencies: [
                "Core",
                "Features",
                "DesignSystem",
                "Services",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/App"
        ),

        // MARK: - Core
        .target(
            name: "Core",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
            path: "Sources/Core"
        ),

        // MARK: - Features
        .target(
            name: "Features",
            dependencies: [
                "Core",
                "DesignSystem",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Features"
        ),

        // MARK: - Design System
        .target(
            name: "DesignSystem",
            dependencies: [],
            path: "Sources/DesignSystem"
        ),

        // MARK: - Services
        .target(
            name: "Services",
            dependencies: [
                "Core",
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
            path: "Sources/Services"
        ),

        // MARK: - Tests
        .testTarget(
            name: "AppTests",
            dependencies: [
                "App",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Tests/AppTests"
        ),
        .testTarget(
            name: "FeaturesTests",
            dependencies: [
                "Features",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Tests/FeaturesTests"
        )
    ],
    swiftLanguageModes: [.v6]
)

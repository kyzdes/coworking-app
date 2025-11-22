import SwiftUI
import ComposableArchitecture

@main
public struct VirtualOfficePomodoroApp: App {
    public init() {}

    public var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
        }
    }
}

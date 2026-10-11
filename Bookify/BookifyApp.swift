import SwiftUI

@main
struct BookifyApp: App {
    @State private var coordinator: AppCoordinator

    init() {
        let coordinator = AppCoordinator(container: DIContainer.makeDefault())
        coordinator.start()
        _coordinator = State(initialValue: coordinator)
    }

    var body: some Scene {
        WindowGroup {
            coordinator.rootView()
                .preferredColorScheme(coordinator.themeMode.colorScheme)
        }
    }
}

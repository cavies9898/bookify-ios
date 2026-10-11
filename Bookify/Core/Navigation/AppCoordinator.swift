import SwiftUI
import Observation

@MainActor
@Observable
final class AppCoordinator {
    enum Phase {
        case auth
        case client
        case admin
    }

    var phase: Phase = .auth
    var themeMode: ThemeMode

    let auth: AuthCoordinator
    let client: ClientCoordinator
    let admin: AdminCoordinator

    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
        self.themeMode = container.preferences.themeMode
        self.auth = AuthCoordinator(factory: AuthSceneFactory(container: container))
        self.client = ClientCoordinator(factory: ClientSceneFactory(container: container))
        self.admin = AdminCoordinator(factory: AdminSceneFactory(container: container))
    }

    func start() {
        auth.app = self
        client.app = self
        admin.app = self
        auth.reset()
        client.reset()
        admin.reset()
        phase = initialPhase()
    }

    func authenticated() {
        auth.reset()
        if container.session.currentUser?.role == .admin {
            admin.reset()
            phase = .admin
        } else {
            client.reset()
            phase = .client
        }
    }

    func registered() {
        auth.reset()
        client.reset()
        phase = .client
    }

    func logout() {
        auth.reset()
        client.reset()
        admin.reset()
        phase = .auth
        Task {
            await container.makeLogout()()
        }
    }

    private func initialPhase() -> Phase {
        guard container.session.isLoggedIn else { return .auth }
        return container.session.currentUser?.role == .admin ? .admin : .client
    }

    @ViewBuilder
    func rootView() -> some View {
        switch phase {
        case .auth:
            AuthFlowView(coordinator: auth)
        case .client:
            ClientHomeView(coordinator: client)
        case .admin:
            AdminHomeView(coordinator: admin)
        }
    }
}

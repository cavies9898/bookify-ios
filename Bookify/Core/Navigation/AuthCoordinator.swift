import SwiftUI
import Observation

@MainActor
@Observable
final class AuthCoordinator {
    enum Route: Hashable {
        case register
        case passwordRecovery
    }

    var path: [Route] = []
    weak var app: AppCoordinator?

    private let factory: AuthSceneFactory

    init(factory: AuthSceneFactory) {
        self.factory = factory
    }

    func reset() {
        path.removeAll()
    }

    @ViewBuilder
    func makeRoot() -> some View {
        factory.makeLogin(coordinator: self)
    }

    @ViewBuilder
    func makeDestination(for route: Route) -> some View {
        switch route {
        case .register:
            factory.makeRegister(coordinator: self)
        case .passwordRecovery:
            factory.makePasswordRecovery(coordinator: self)
        }
    }
}

extension AuthCoordinator: LoginViewModelOutput {
    func loginSucceeded() {
        app?.authenticated()
    }

    func registerRequested() {
        path.append(.register)
    }

    func passwordRecoveryRequested() {
        path.append(.passwordRecovery)
    }
}

extension AuthCoordinator: RegisterViewModelOutput {
    func registerSucceeded() {
        app?.registered()
    }

    func closeRegister() {
        pop()
    }
}

extension AuthCoordinator: PasswordRecoveryViewModelOutput {
    func closeRecovery() {
        pop()
    }
}

private extension AuthCoordinator {
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

import SwiftUI

struct AuthSceneFactory {
    let container: DIContainer

    func makeLogin(coordinator: AuthCoordinator) -> LoginView {
        LoginView(viewModel: LoginViewModel(login: container.makeLogin(), output: coordinator))
    }

    func makeRegister(coordinator: AuthCoordinator) -> RegisterView {
        RegisterView(viewModel: RegisterViewModel(register: container.makeRegister(), output: coordinator))
    }

    func makePasswordRecovery(coordinator: AuthCoordinator) -> PasswordRecoveryView {
        PasswordRecoveryView(
            viewModel: PasswordRecoveryViewModel(
                forgotPassword: container.makeForgotPassword(),
                resetPassword: container.makeResetPassword(),
                output: coordinator
            )
        )
    }
}

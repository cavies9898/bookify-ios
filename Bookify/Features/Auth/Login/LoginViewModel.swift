import Foundation
import Observation

@MainActor
protocol LoginViewModelOutput: AnyObject {
    func loginSucceeded()
    func registerRequested()
    func passwordRecoveryRequested()
}

@MainActor
@Observable
final class LoginViewModel {
    struct UiState {
        var email = ""
        var password = ""
        var isLoading = false
        var emailError: String?
        var passwordError: String?
        var errorMessage: String?
    }

    var state = UiState()
    private let login: Login
    weak var output: LoginViewModelOutput?

    init(login: Login, output: LoginViewModelOutput) {
        self.login = login
        self.output = output
    }

    func submit() async {
        guard !state.isLoading else { return }
        state.isLoading = true
        state.errorMessage = nil
        let result = await login(email: state.email, password: state.password)
        state.isLoading = false
        switch result {
        case .success:
            output?.loginSucceeded()
        case .failure(let error):
            if case .validation(let validation) = error {
                switch validation.field {
                case .email:
                    state.emailError = validation.message
                case .password:
                    state.passwordError = validation.message
                default:
                    break
                }
            } else {
                state.errorMessage = error.message ?? "Error desconocido"
            }
        }
    }
}

import Foundation
import Observation

@MainActor
protocol RegisterViewModelOutput: AnyObject {
    func registerSucceeded()
    func closeRegister()
}

@MainActor
@Observable
final class RegisterViewModel {
    struct UiState {
        var name = ""
        var email = ""
        var password = ""
        var isLoading = false
        var nameError: String?
        var emailError: String?
        var passwordError: String?
        var errorMessage: String?
    }

    var state = UiState()
    private let register: Register
    weak var output: RegisterViewModelOutput?

    init(register: Register, output: RegisterViewModelOutput) {
        self.register = register
        self.output = output
    }

    func submit() async {
        guard !state.isLoading else { return }
        state.isLoading = true
        state.errorMessage = nil
        let result = await register(name: state.name, email: state.email, password: state.password)
        state.isLoading = false
        switch result {
        case .success:
            output?.registerSucceeded()
        case .failure(let error):
            if case .validation(let validation) = error {
                switch validation.field {
                case .name:
                    state.nameError = validation.message
                case .email:
                    state.emailError = validation.message
                case .password:
                    state.passwordError = validation.message
                default:
                    break
                }
            } else {
                state.errorMessage = error.message ?? "Error del servidor"
            }
        }
    }
}

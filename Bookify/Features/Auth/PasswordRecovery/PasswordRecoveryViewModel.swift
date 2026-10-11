import Foundation
import Observation

@MainActor
protocol PasswordRecoveryViewModelOutput: AnyObject {
    func closeRecovery()
}

@MainActor
@Observable
final class PasswordRecoveryViewModel {
    struct UiState {
        var step = 1
        var email = ""
        var code = ""
        var newPassword = ""
        var confirmPassword = ""
        var serverMessage: String?
        var isLoading = false
        var emailError: String?
        var codeError: String?
        var newPasswordError: String?
        var confirmPasswordError: String?
        var errorMessage: String?
    }

    var state = UiState()
    private let forgotPasswordUseCase: ForgotPassword
    private let resetPasswordUseCase: ResetPassword
    weak var output: PasswordRecoveryViewModelOutput?

    init(forgotPassword: ForgotPassword, resetPassword: ResetPassword, output: PasswordRecoveryViewModelOutput) {
        forgotPasswordUseCase = forgotPassword
        resetPasswordUseCase = resetPassword
        self.output = output
    }

    func requestCode() async {
        guard !state.isLoading else { return }
        state.isLoading = true
        state.errorMessage = nil
        let result = await forgotPasswordUseCase(email: state.email)
        state.isLoading = false
        switch result {
        case .success(let message):
            state.serverMessage = message
            state.step = 2
        case .failure(let error):
            if case .validation(let validation) = error {
                state.emailError = validation.message
            } else {
                state.errorMessage = error.message ?? "Error del servidor"
            }
        }
    }

    func resetPassword() async {
        guard !state.isLoading else { return }
        state.isLoading = true
        state.errorMessage = nil
        let result = await resetPasswordUseCase(
            code: state.code,
            newPassword: state.newPassword,
            confirmPassword: state.confirmPassword
        )
        state.isLoading = false
        switch result {
        case .success:
            state.step = 3
        case .failure(let error):
            if case .validation(let validation) = error {
                switch validation.field {
                case .code:
                    state.codeError = validation.message
                case .password:
                    state.newPasswordError = validation.message
                case .confirmPassword:
                    state.confirmPasswordError = validation.message
                default:
                    break
                }
            } else {
                state.errorMessage = error.message ?? "Error del servidor"
            }
        }
    }

    func backToStart() {
        output?.closeRecovery()
    }
}

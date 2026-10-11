import Foundation

struct ResetPassword {
    private let auth: AuthRepository

    init(auth: AuthRepository) {
        self.auth = auth
    }

    func callAsFunction(code: String, newPassword: String, confirmPassword: String) async -> AppResult<String> {
        if code.isEmpty {
            return .failure(.validation(.emptyCode))
        }
        if code.count != 6 {
            return .failure(.validation(.invalidCodeLength))
        }
        if newPassword.isEmpty {
            return .failure(.validation(.emptyPassword))
        }
        if let error = PasswordPolicy.error(for: newPassword) {
            return .failure(.validation(error))
        }
        if newPassword != confirmPassword {
            return .failure(.validation(.passwordsDoNotMatch))
        }
        return await .catching {
            try await auth.resetPassword(token: code, newPassword: newPassword)
        }
    }
}

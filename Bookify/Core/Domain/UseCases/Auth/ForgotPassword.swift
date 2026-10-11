import Foundation

struct ForgotPassword {
    private let auth: AuthRepository

    init(auth: AuthRepository) {
        self.auth = auth
    }

    func callAsFunction(email: String) async -> AppResult<String> {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if let error = EmailValidation.error(for: trimmedEmail) {
            return .failure(.validation(error))
        }
        return await .catching {
            try await auth.forgotPassword(email: trimmedEmail)
        }
    }
}

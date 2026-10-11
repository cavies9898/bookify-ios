import Foundation

struct Login {
    private let auth: AuthRepository
    private let session: SessionStore

    init(auth: AuthRepository, session: SessionStore) {
        self.auth = auth
        self.session = session
    }

    func callAsFunction(email: String, password: String) async -> AppResult<Void> {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if let error = EmailValidation.error(for: trimmedEmail) {
            return .failure(.validation(error))
        }
        if let error = PasswordPolicy.error(for: password) {
            return .failure(.validation(error))
        }
        return await .catching {
            let response = try await auth.login(email: trimmedEmail, password: password)
            session.save(response)
        }
    }
}

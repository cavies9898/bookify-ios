import Foundation

struct Register {
    private let auth: AuthRepository
    private let session: SessionStore

    init(auth: AuthRepository, session: SessionStore) {
        self.auth = auth
        self.session = session
    }

    func callAsFunction(name: String, email: String, password: String) async -> AppResult<Void> {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            return .failure(.validation(.emptyName))
        }
        if trimmedName.count < 2 {
            return .failure(.validation(.shortName))
        }
        if let error = EmailValidation.error(for: trimmedEmail) {
            return .failure(.validation(error))
        }
        if let error = PasswordPolicy.error(for: password) {
            return .failure(.validation(error))
        }
        return await .catching {
            let response = try await auth.register(name: trimmedName, email: trimmedEmail, password: password)
            session.save(response)
        }
    }
}

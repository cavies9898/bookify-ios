import Foundation

struct Logout {
    private let auth: AuthRepository
    private let session: SessionStore

    init(auth: AuthRepository, session: SessionStore) {
        self.auth = auth
        self.session = session
    }

    func callAsFunction() async {
        try? await auth.logout()
        session.logout()
    }
}

struct GetCurrentUser {
    private let session: SessionStore

    init(session: SessionStore) {
        self.session = session
    }

    func callAsFunction() -> User? {
        session.currentUser
    }
}

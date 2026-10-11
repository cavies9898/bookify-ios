import Foundation

@MainActor
protocol SessionStore: AnyObject {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    var isLoggedIn: Bool { get }
    var currentUser: User? { get }
    func save(_ auth: AuthResponse)
    func saveTokens(accessToken: String, refreshToken: String)
    func logout()
}

@MainActor
final class KeychainSessionStore: SessionStore {
    private let keychain: KeychainStore

    init(keychain: KeychainStore) {
        self.keychain = keychain
    }

    var accessToken: String? {
        keychain.string(forKey: StorageKey.accessToken)
    }

    var refreshToken: String? {
        keychain.string(forKey: StorageKey.refreshToken)
    }

    var isLoggedIn: Bool {
        accessToken != nil
    }

    var currentUser: User? {
        guard let idValue = keychain.string(forKey: StorageKey.userId),
              let id = Int(idValue),
              let name = keychain.string(forKey: StorageKey.userName),
              let email = keychain.string(forKey: StorageKey.userEmail)
        else { return nil }
        let roleValue = keychain.string(forKey: StorageKey.userRole) ?? ""
        return User(id: id, name: name, email: email, role: UserRole(rawValue: roleValue) ?? .cliente)
    }

    func save(_ auth: AuthResponse) {
        saveTokens(accessToken: auth.accessToken, refreshToken: auth.refreshToken)
        keychain.removeAll(StorageKey.userKeys)
        if let user = auth.user {
            keychain.set(String(user.id), forKey: StorageKey.userId)
            keychain.set(user.name, forKey: StorageKey.userName)
            keychain.set(user.email, forKey: StorageKey.userEmail)
            keychain.set(user.role.rawValue, forKey: StorageKey.userRole)
        }
    }

    func saveTokens(accessToken: String, refreshToken: String) {
        keychain.set(accessToken, forKey: StorageKey.accessToken)
        keychain.set(refreshToken, forKey: StorageKey.refreshToken)
    }

    func logout() {
        keychain.removeAll(StorageKey.all)
    }
}

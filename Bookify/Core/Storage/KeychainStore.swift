import Foundation
import Security
import os

enum StorageKey {
    static let accessToken = "access_token"
    static let refreshToken = "refresh_token"
    static let userId = "user_id"
    static let userName = "user_name"
    static let userEmail = "user_email"
    static let userRole = "user_role"

    static let all: [String] = [accessToken, refreshToken, userId, userName, userEmail, userRole]
    static let userKeys: [String] = [userId, userName, userEmail, userRole]
}

@MainActor
final class KeychainStore {
    private let service: String
    private let logger = Logger(subsystem: "com.cavies.Bookify", category: "Keychain")

    init(service: String = "bookify_secure_prefs") {
        self.service = service
    }

    func string(forKey key: String) -> String? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else {
            logger.error("Keychain read failed for \(key, privacy: .public): \(status)")
            return nil
        }
        guard let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    func set(_ value: String, forKey key: String) -> Bool {
        let data = Data(value.utf8)
        let query = baseQuery(for: key)
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData as String] = data
            addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                logger.error("Keychain add failed for \(key, privacy: .public): \(addStatus)")
                return false
            }
            return true
        }
        guard status == errSecSuccess else {
            logger.error("Keychain update failed for \(key, privacy: .public): \(status)")
            return false
        }
        return true
    }

    @discardableResult
    func remove(_ key: String) -> Bool {
        let status = SecItemDelete(baseQuery(for: key) as CFDictionary)
        if status == errSecSuccess || status == errSecItemNotFound { return true }
        logger.error("Keychain delete failed for \(key, privacy: .public): \(status)")
        return false
    }

    func removeAll(_ keys: [String]) {
        for key in keys {
            remove(key)
        }
    }

    private func baseQuery(for key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }
}

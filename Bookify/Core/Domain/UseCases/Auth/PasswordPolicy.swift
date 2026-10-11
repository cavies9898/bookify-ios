import Foundation

enum PasswordPolicy {
    static let minimumLength = 8

    static func error(for password: String) -> ValidationError? {
        if password.isEmpty { return .emptyPassword }
        if password.count < minimumLength {
            return .shortPassword(minimum: minimumLength)
        }
        let hasLetter = password.rangeOfCharacter(from: .letters) != nil
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil
        guard hasLetter, hasDigit else { return .weakPassword }
        return nil
    }
}

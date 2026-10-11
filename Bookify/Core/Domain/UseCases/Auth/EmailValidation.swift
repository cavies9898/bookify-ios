import Foundation

enum EmailValidation {
    static func error(for email: String) -> ValidationError? {
        if email.isEmpty { return .emptyEmail }
        if !email.contains("@") || !email.contains(".") { return .invalidEmail }
        return nil
    }
}

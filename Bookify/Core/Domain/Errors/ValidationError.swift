import Foundation

enum ValidationError: LocalizedError, Equatable, Sendable {
    enum Field: Hashable, Sendable {
        case name
        case email
        case password
        case code
        case newPassword
        case confirmPassword
    }

    case emptyName
    case shortName
    case emptyEmail
    case invalidEmail
    case emptyPassword
    case shortPassword(minimum: Int)
    case weakPassword
    case emptyCode
    case invalidCodeLength
    case passwordsDoNotMatch

    var message: String {
        switch self {
        case .emptyName:
            "El nombre es obligatorio"
        case .shortName:
            "El nombre debe tener al menos 2 caracteres"
        case .emptyEmail:
            "El correo electrónico es obligatorio"
        case .invalidEmail:
            "Ingresa un correo electrónico válido"
        case .emptyPassword:
            "La contraseña es obligatoria"
        case .shortPassword(let minimum):
            "La contraseña debe tener al menos \(minimum) caracteres"
        case .weakPassword:
            "La contraseña debe incluir al menos una letra y un número"
        case .emptyCode:
            "El código es obligatorio"
        case .invalidCodeLength:
            "El código debe tener 6 caracteres"
        case .passwordsDoNotMatch:
            "Las contraseñas no coinciden"
        }
    }

    var field: Field {
        switch self {
        case .emptyName, .shortName: .name
        case .emptyEmail, .invalidEmail: .email
        case .emptyPassword, .shortPassword, .weakPassword: .password
        case .emptyCode, .invalidCodeLength: .code
        case .passwordsDoNotMatch: .confirmPassword
        }
    }

    var errorDescription: String? { message }
}

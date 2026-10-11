import Foundation

enum AppError: LocalizedError, Equatable, Sendable {
    case validation(ValidationError)
    case status(Int)
    case offline
    case timeout
    case server
    case unknown

    var message: String? {
        switch self {
        case .validation(let error):
            error.message
        case .status(let code):
            ErrorMapper.message(for: code)
        case .offline:
            "Sin conexión a internet"
        case .timeout:
            "Tiempo de espera agotado"
        case .server:
            "Error del servidor"
        case .unknown:
            nil
        }
    }

    var errorDescription: String? { message }
}

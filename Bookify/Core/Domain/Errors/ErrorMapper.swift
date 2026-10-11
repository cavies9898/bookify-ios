import Foundation

enum ErrorMapper {
    static func message(for statusCode: Int) -> String {
        switch statusCode {
        case 400: "Solicitud inválida"
        case 401: "Credenciales incorrectas"
        case 403: "No tienes permiso"
        case 404: "Recurso no encontrado"
        case 409: "Conflicto con el recurso existente"
        case 422: "Datos inválidos"
        case 500: "Error interno del servidor"
        case 502: "Servidor no disponible"
        case 503: "Servicio no disponible"
        default: "Error del servidor (\(statusCode))"
        }
    }
}

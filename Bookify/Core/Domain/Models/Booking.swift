import Foundation

enum BookingStatus: String, Codable, Hashable, Sendable, CaseIterable {
    case pending = "PENDING"
    case confirmed = "CONFIRMED"
    case cancelled = "CANCELLED"

    var label: String {
        switch self {
        case .pending: "Pendiente"
        case .confirmed: "Confirmada"
        case .cancelled: "Cancelada"
        }
    }
}

struct Booking: Identifiable, Hashable, Sendable {
    let id: Int
    let userId: Int?
    let serviceId: Int
    let serviceName: String?
    let servicePrice: Double?
    let startAt: String
    let endAt: String
    let status: BookingStatus
    let createdAt: String?
    let updatedAt: String?
    let userName: String?
    let userEmail: String?
}

import Foundation

enum UserRole: String, Codable, Hashable, Sendable {
    case admin = "ADMIN"
    case cliente = "CLIENTE"
}

struct User: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let email: String
    let role: UserRole
}

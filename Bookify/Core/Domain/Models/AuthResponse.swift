import Foundation

struct AuthResponse: Hashable, Sendable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String?
    let expiresIn: Int?
    let user: User?
}

struct ServerMessage: Hashable, Sendable {
    let message: String
}

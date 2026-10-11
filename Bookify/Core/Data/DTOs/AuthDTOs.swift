import Foundation

struct AuthDTO: Decodable {
    let accessToken: String?
    let refreshToken: String?
    let tokenType: String?
    let expiresIn: Int?
    let user: UserDTO?

    var domain: AuthResponse {
        AuthResponse(
            accessToken: accessToken ?? "",
            refreshToken: refreshToken ?? "",
            tokenType: tokenType,
            expiresIn: expiresIn,
            user: user?.domain
        )
    }
}

struct UserDTO: Decodable {
    let id: Int?
    let name: String?
    let email: String?
    let role: String?

    var domain: User {
        User(
            id: id ?? 0,
            name: name ?? "",
            email: email ?? "",
            role: role.flatMap(UserRole.init(rawValue:)) ?? .cliente
        )
    }
}

struct MessageDTO: Decodable {
    let message: String?

    var domain: String { message ?? "" }
}

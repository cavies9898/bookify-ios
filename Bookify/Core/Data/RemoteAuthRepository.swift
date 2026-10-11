import Foundation

struct RemoteAuthRepository: AuthRepository {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let endpoint = Endpoint(
            path: "api/auth/login",
            method: .post,
            body: CredentialsBody(email: email, password: password),
            requiresAuth: false
        )
        let dto: AuthDTO = try await client.request(endpoint)
        return dto.domain
    }

    func register(name: String, email: String, password: String) async throws -> AuthResponse {
        let endpoint = Endpoint(
            path: "api/auth/register",
            method: .post,
            body: RegisterBody(name: name, email: email, password: password),
            requiresAuth: false
        )
        let dto: AuthDTO = try await client.request(endpoint)
        return dto.domain
    }

    func forgotPassword(email: String) async throws -> String {
        let endpoint = Endpoint(
            path: "api/auth/forgot-password",
            method: .post,
            body: EmailBody(email: email),
            requiresAuth: false
        )
        let dto: MessageDTO = try await client.request(endpoint)
        return dto.domain
    }

    func resetPassword(token: String, newPassword: String) async throws -> String {
        let endpoint = Endpoint(
            path: "api/auth/reset-password",
            method: .post,
            body: ResetBody(token: token, newPassword: newPassword),
            requiresAuth: false
        )
        let dto: MessageDTO = try await client.request(endpoint)
        return dto.domain
    }

    func logout() async throws {
        let endpoint = Endpoint(
            path: "api/auth/logout",
            method: .post
        )
        try await client.requestVoid(endpoint)
    }
}

private struct CredentialsBody: Encodable {
    let email: String
    let password: String
}

private struct RegisterBody: Encodable {
    let name: String
    let email: String
    let password: String
}

private struct EmailBody: Encodable {
    let email: String
}

private struct ResetBody: Encodable {
    let token: String
    let newPassword: String
}

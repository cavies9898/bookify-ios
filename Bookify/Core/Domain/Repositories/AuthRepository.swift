import Foundation

@MainActor
protocol AuthRepository {
    func login(email: String, password: String) async throws -> AuthResponse
    func register(name: String, email: String, password: String) async throws -> AuthResponse
    func forgotPassword(email: String) async throws -> String
    func resetPassword(token: String, newPassword: String) async throws -> String
    func logout() async throws
}

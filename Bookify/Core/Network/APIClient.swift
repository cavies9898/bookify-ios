import Foundation

@MainActor
protocol HTTPClient {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func requestVoid(_ endpoint: Endpoint) async throws
}

@MainActor
final class APIClient: HTTPClient {
    private let baseURL: URL
    private let session: URLSession
    private let sessionStore: SessionStore
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var refreshTask: Task<RefreshedTokens, Error>?

    init(baseURL: URL, session: URLSession, sessionStore: SessionStore) {
        self.baseURL = baseURL
        self.session = session
        self.sessionStore = sessionStore
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var (data, response) = try await perform(endpoint)
        if response.statusCode == 401, endpoint.requiresAuth {
            _ = try await refreshTokens()
            (data, response) = try await perform(endpoint)
        }
        guard (200..<300).contains(response.statusCode) else {
            throw AppError.status(response.statusCode)
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AppError.unknown
        }
    }

    func requestVoid(_ endpoint: Endpoint) async throws {
        var (_, response) = try await perform(endpoint)
        if response.statusCode == 401, endpoint.requiresAuth {
            _ = try await refreshTokens()
            (_, response) = try await perform(endpoint)
        }
        guard (200..<300).contains(response.statusCode) else {
            throw AppError.status(response.statusCode)
        }
    }

    private func refreshTokens() async throws -> RefreshedTokens {
        if let refreshTask {
            do {
                return try await refreshTask.value
            } catch {
                throw AppError.status(401)
            }
        }
        guard let currentRefreshToken = sessionStore.refreshToken, !currentRefreshToken.isEmpty else {
            throw AppError.status(401)
        }
        let task = Task { [weak self] in
            guard let self else { throw AppError.status(401) }
            return try await self.performRefresh(refreshToken: currentRefreshToken)
        }
        refreshTask = task
        defer { refreshTask = nil }
        do {
            let tokens = try await task.value
            sessionStore.saveTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
            return tokens
        } catch {
            throw AppError.status(401)
        }
    }

    private func performRefresh(refreshToken: String) async throws -> RefreshedTokens {
        let endpoint = Endpoint(
            path: "api/auth/refresh",
            method: .post,
            body: RefreshRequest(refreshToken: refreshToken),
            requiresAuth: false
        )
        let (data, response) = try await perform(endpoint)
        guard (200..<300).contains(response.statusCode) else {
            throw AppError.status(response.statusCode)
        }
        guard let tokens = try? decoder.decode(RefreshedTokens.self, from: data),
              !tokens.accessToken.isEmpty,
              !tokens.refreshToken.isEmpty else {
            throw AppError.status(401)
        }
        return tokens
    }

    private func perform(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse) {
        let request = try makeRequest(endpoint)
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw AppError.unknown }
            return (data, http)
        } catch let error as URLError {
            throw map(error)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.unknown
        }
    }

    private func makeRequest(_ endpoint: Endpoint) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw AppError.unknown
        }
        let basePath = components.path
        if basePath.isEmpty {
            components.path = "/" + endpoint.path
        } else if basePath.hasSuffix("/") {
            components.path = basePath + endpoint.path
        } else {
            components.path = basePath + "/" + endpoint.path
        }
        components.queryItems = endpoint.query.isEmpty ? nil : endpoint.query
        guard let url = components.url else { throw AppError.unknown }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        if endpoint.body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if endpoint.requiresAuth, let token = sessionStore.accessToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try endpoint.body.map { try encoder.encode(AnyEncodable($0)) }
        return request
    }

    private func map(_ error: URLError) -> AppError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed,
             .internationalRoamingOff, .cannotFindHost, .cannotConnectToHost:
            return .offline
        case .timedOut:
            return .timeout
        default:
            return .server
        }
    }
}

private struct RefreshRequest: Encodable {
    let refreshToken: String
}

private struct RefreshedTokens: Decodable {
    let accessToken: String
    let refreshToken: String
}

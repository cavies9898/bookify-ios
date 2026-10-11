import Foundation

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let query: [URLQueryItem]
    let body: (any Encodable)?
    let requiresAuth: Bool

    init(
        path: String,
        method: HTTPMethod = .get,
        query: [URLQueryItem] = [],
        body: (any Encodable)? = nil,
        requiresAuth: Bool = true
    ) {
        self.path = path
        self.method = method
        self.query = query
        self.body = body
        self.requiresAuth = requiresAuth
    }
}

struct AnyEncodable: Encodable {
    private let encoded: (Encoder) throws -> Void

    init(_ wrapped: some Encodable) {
        encoded = { try wrapped.encode(to: $0) }
    }

    func encode(to encoder: Encoder) throws {
        try encoded(encoder)
    }
}

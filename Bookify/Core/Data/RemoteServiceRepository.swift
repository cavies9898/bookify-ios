import Foundation

struct RemoteServiceRepository: ServiceRepository {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchServices(page: Int, size: Int) async throws -> PaginatedResponse<Service> {
        let endpoint = Endpoint(
            path: "api/services",
            query: [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size)),
                URLQueryItem(name: "sort", value: "name,asc")
            ]
        )
        let dto: PageDTO<ServiceDTO> = try await client.request(endpoint)
        return dto.mapped { $0.domain }
    }

    func fetchAvailability(serviceId: Int, date: String) async throws -> AvailabilityResponse {
        let endpoint = Endpoint(
            path: "api/services/\(serviceId)/availability",
            query: [URLQueryItem(name: "date", value: date)]
        )
        let dto: AvailabilityDTO = try await client.request(endpoint)
        return dto.domain
    }

    func create(_ params: ServiceParams) async throws -> Service {
        let endpoint = Endpoint(path: "api/services", method: .post, body: params.dto)
        let dto: ServiceDTO = try await client.request(endpoint)
        return dto.domain
    }

    func update(id: Int, _ params: ServiceParams) async throws -> Service {
        let endpoint = Endpoint(path: "api/services/\(id)", method: .put, body: params.dto)
        let dto: ServiceDTO = try await client.request(endpoint)
        return dto.domain
    }

    func delete(id: Int) async throws {
        let endpoint = Endpoint(path: "api/services/\(id)", method: .delete)
        try await client.requestVoid(endpoint)
    }
}

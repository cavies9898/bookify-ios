import Foundation

struct RemoteBookingRepository: BookingRepository {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchBookings(page: Int, size: Int, status: BookingStatus?) async throws -> PaginatedResponse<Booking> {
        var query = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size)),
            URLQueryItem(name: "sort", value: "startAt,desc")
        ]
        if let status {
            query.append(URLQueryItem(name: "status", value: status.rawValue))
        }
        let endpoint = Endpoint(path: "api/bookings", query: query)
        let dto: PageDTO<BookingDTO> = try await client.request(endpoint)
        return dto.mapped { $0.domain }
    }

    func create(serviceId: Int, startAt: String, endAt: String) async throws -> Booking {
        let endpoint = Endpoint(
            path: "api/bookings",
            method: .post,
            body: BookingCreateDTO(serviceId: serviceId, startAt: startAt, endAt: endAt)
        )
        let dto: BookingDTO = try await client.request(endpoint)
        return dto.domain
    }

    func delete(id: Int) async throws {
        let endpoint = Endpoint(path: "api/bookings/\(id)", method: .delete)
        try await client.requestVoid(endpoint)
    }
}

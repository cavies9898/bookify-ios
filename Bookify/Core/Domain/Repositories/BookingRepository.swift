import Foundation

@MainActor
protocol BookingRepository {
    func fetchBookings(page: Int, size: Int, status: BookingStatus?) async throws -> PaginatedResponse<Booking>
    func create(serviceId: Int, startAt: String, endAt: String) async throws -> Booking
    func delete(id: Int) async throws
}

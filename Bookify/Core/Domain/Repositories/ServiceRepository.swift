import Foundation

@MainActor
protocol ServiceRepository {
    func fetchServices(page: Int, size: Int) async throws -> PaginatedResponse<Service>
    func fetchAvailability(serviceId: Int, date: String) async throws -> AvailabilityResponse
    func create(_ params: ServiceParams) async throws -> Service
    func update(id: Int, _ params: ServiceParams) async throws -> Service
    func delete(id: Int) async throws
}

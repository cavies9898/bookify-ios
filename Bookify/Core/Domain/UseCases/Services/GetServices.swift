import Foundation

struct GetServices {
    private let services: ServiceRepository

    init(services: ServiceRepository) {
        self.services = services
    }

    func callAsFunction(page: Int, size: Int = 10) async -> AppResult<PaginatedResponse<Service>> {
        await .catching {
            try await services.fetchServices(page: page, size: size)
        }
    }
}

struct GetServiceAvailability {
    private let services: ServiceRepository

    init(services: ServiceRepository) {
        self.services = services
    }

    func callAsFunction(serviceId: Int, date: String) async -> AppResult<AvailabilityResponse> {
        await .catching {
            try await services.fetchAvailability(serviceId: serviceId, date: date)
        }
    }
}

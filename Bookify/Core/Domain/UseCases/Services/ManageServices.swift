import Foundation

struct CreateService {
    private let services: ServiceRepository

    init(services: ServiceRepository) {
        self.services = services
    }

    func callAsFunction(params: ServiceParams) async -> AppResult<Service> {
        await .catching {
            try await services.create(params)
        }
    }
}

struct UpdateService {
    private let services: ServiceRepository

    init(services: ServiceRepository) {
        self.services = services
    }

    func callAsFunction(id: Int, params: ServiceParams) async -> AppResult<Service> {
        await .catching {
            try await services.update(id: id, params)
        }
    }
}

struct DeleteService {
    private let services: ServiceRepository

    init(services: ServiceRepository) {
        self.services = services
    }

    func callAsFunction(id: Int) async -> AppResult<Void> {
        await .catching {
            try await services.delete(id: id)
        }
    }
}

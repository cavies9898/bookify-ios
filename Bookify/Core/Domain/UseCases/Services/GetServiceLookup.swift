import Foundation

struct GetServiceById {
    private let services: ServiceRepository

    init(services: ServiceRepository) {
        self.services = services
    }

    func callAsFunction(id: Int) async -> AppResult<Service?> {
        let result: AppResult<PaginatedResponse<Service>> = await .catching {
            try await services.fetchServices(page: 0, size: 100)
        }
        switch result {
        case .success(let page):
            return .success(page.content.first { $0.id == id })
        case .failure(let error):
            return .failure(error)
        }
    }
}

struct GetServiceNames {
    private let services: ServiceRepository

    init(services: ServiceRepository) {
        self.services = services
    }

    func callAsFunction() async -> [Int: String] {
        let result: AppResult<PaginatedResponse<Service>> = await .catching {
            try await services.fetchServices(page: 0, size: 100)
        }
        guard case .success(let page) = result else { return [:] }
        return Dictionary(page.content.map { ($0.id, $0.name) }) { _, last in last }
    }
}

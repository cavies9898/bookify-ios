import Foundation
import Observation

@MainActor
protocol AdminServiceListOutput: AnyObject {
    func createServiceRequested()
}

@MainActor
@Observable
final class AdminServiceListViewModel {
    struct UiState {
        var services: [Service] = []
        var isLoading = false
        var errorMessage: String?
        var deleteErrorMessage: String?
        var hasLoaded = false
    }

    var state = UiState()
    private let getServices: GetServices
    private let deleteService: DeleteService
    weak var output: AdminServiceListOutput?

    init(getServices: GetServices, deleteService: DeleteService, output: AdminServiceListOutput) {
        self.getServices = getServices
        self.deleteService = deleteService
        self.output = output
    }

    func loadInitial() async {
        guard !state.hasLoaded else { return }
        await refresh()
        state.hasLoaded = true
    }

    func refresh() async {
        state.isLoading = true
        let result = await getServices(page: 0, size: 100)
        state.isLoading = false
        switch result {
        case .success(let page):
            state.services = page.content
            state.errorMessage = nil
        case .failure(let error):
            state.errorMessage = error.message ?? "Error al cargar servicios"
        }
    }

    func delete(_ service: Service) async {
        guard !state.isLoading else { return }
        state.isLoading = true
        let result = await deleteService(id: service.id)
        state.isLoading = false
        switch result {
        case .success:
            await refresh()
        case .failure(let error):
            state.deleteErrorMessage = error.message ?? "Error del servidor"
        }
    }

    func create() {
        output?.createServiceRequested()
    }
}

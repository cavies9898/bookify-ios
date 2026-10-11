import Foundation
import Observation

@MainActor
protocol ServiceListOutput: AnyObject {
    func openService(_ service: Service)
}

@MainActor
@Observable
final class ServiceListViewModel {
    struct UiState {
        var services: [Service] = []
        var isLoading = false
        var isLoadingMore = false
        var errorMessage: String?
        var page = 0
        var hasMore = true
        var hasLoaded = false
    }

    var state = UiState()
    private let getServices: GetServices
    weak var output: ServiceListOutput?

    init(getServices: GetServices, output: ServiceListOutput) {
        self.getServices = getServices
        self.output = output
    }

    func loadInitial() async {
        guard !state.hasLoaded else { return }
        await load(page: 0)
        state.hasLoaded = true
    }

    func refresh() async {
        await load(page: 0)
    }

    func loadNextPage() {
        guard state.hasMore, !state.isLoading, !state.isLoadingMore else { return }
        Task { await loadMore() }
    }

    func loadMoreIfNeeded(index: Int) {
        if index >= 7 && state.hasMore && !state.isLoading && !state.isLoadingMore {
            Task { await loadMore() }
        }
    }

    private func loadMore() async {
        guard state.hasMore, !state.isLoading, !state.isLoadingMore else { return }
        await load(page: state.page + 1)
    }

    private func load(page: Int) async {
        if page == 0 {
            state.isLoading = true
        } else {
            state.isLoadingMore = true
        }
        let result = await getServices(page: page)
        if page == 0 {
            state.isLoading = false
        } else {
            state.isLoadingMore = false
        }
        switch result {
        case .success(let response):
            if page == 0 {
                state.services = response.content
            } else {
                state.services.append(contentsOf: response.content)
            }
            state.page = page
            state.hasMore = !response.last
            state.errorMessage = nil
        case .failure(let error):
            if state.services.isEmpty {
                state.errorMessage = error.message ?? "Error al cargar servicios"
            }
        }
    }
}

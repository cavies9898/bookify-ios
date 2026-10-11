import SwiftUI

struct AdminServiceListRoot: View {
    @State private var viewModel: AdminServiceListViewModel
    let coordinator: AdminCoordinator

    init(factory: AdminSceneFactory, coordinator: AdminCoordinator) {
        _viewModel = State(initialValue: factory.makeServiceListViewModel(coordinator: coordinator))
        self.coordinator = coordinator
    }

    var body: some View {
        AdminServiceListView(viewModel: viewModel, coordinator: coordinator)
    }
}

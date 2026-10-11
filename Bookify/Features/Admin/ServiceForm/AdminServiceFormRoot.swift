import SwiftUI

struct AdminServiceFormRoot: View {
    @State private var viewModel: ServiceFormViewModel

    init(mode: ServiceFormMode, factory: AdminSceneFactory, coordinator: AdminCoordinator) {
        _viewModel = State(initialValue: factory.makeServiceFormViewModel(mode: mode, coordinator: coordinator))
    }

    var body: some View {
        ServiceFormView(viewModel: viewModel)
    }
}

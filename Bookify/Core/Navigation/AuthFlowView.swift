import SwiftUI

struct AuthFlowView: View {
    @Bindable var coordinator: AuthCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.makeRoot()
                .navigationDestination(for: AuthCoordinator.Route.self) { route in
                    coordinator.makeDestination(for: route)
                }
        }
    }
}

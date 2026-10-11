import SwiftUI

struct ClientHomeView: View {
    @Bindable var coordinator: ClientCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            NavigationStack(path: $coordinator.servicesPath) {
                coordinator.makeServicesRoot()
                    .navigationTitle("Servicios")
                    .navigationDestination(for: ClientCoordinator.Route.self) { route in
                        coordinator.makeDestination(for: route)
                    }
            }
            .tabItem { Label("Servicios", systemImage: "square.grid.2x2.fill") }
            .tag(ClientCoordinator.Tab.services)

            NavigationStack(path: $coordinator.bookingsPath) {
                coordinator.makeBookingsRoot()
                    .navigationTitle("Reservas")
                    .navigationDestination(for: ClientCoordinator.Route.self) { route in
                        coordinator.makeDestination(for: route)
                    }
            }
            .tabItem { Label("Reservas", systemImage: "calendar") }
            .tag(ClientCoordinator.Tab.bookings)

            NavigationStack {
                coordinator.makeProfileRoot()
                    .navigationTitle("Perfil")
            }
            .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
            .tag(ClientCoordinator.Tab.profile)
        }
    }
}

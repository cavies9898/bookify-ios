import SwiftUI

struct AdminHomeView: View {
    @Bindable var coordinator: AdminCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            NavigationStack(path: $coordinator.servicesPath) {
                coordinator.makeServicesRoot()
                    .navigationTitle("Servicios")
                    .navigationDestination(for: AdminCoordinator.Route.self) { route in
                        coordinator.makeDestination(for: route)
                    }
            }
            .tabItem { Label("Servicios", systemImage: "square.grid.2x2.fill") }
            .tag(AdminCoordinator.Tab.services)

            NavigationStack(path: $coordinator.bookingsPath) {
                coordinator.makeBookingsRoot()
                    .navigationTitle("Reservas")
                    .navigationDestination(for: AdminCoordinator.Route.self) { route in
                        coordinator.makeDestination(for: route)
                    }
            }
            .tabItem { Label("Reservas", systemImage: "calendar") }
            .tag(AdminCoordinator.Tab.bookings)

            NavigationStack {
                coordinator.makeProfileRoot()
                    .navigationTitle("Perfil")
            }
            .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
            .tag(AdminCoordinator.Tab.profile)
        }
    }
}

import SwiftUI
import Observation

@MainActor
@Observable
final class ClientCoordinator {
    enum Tab: Hashable {
        case services
        case bookings
        case profile
    }

    enum Route: Hashable {
        case serviceDetail(Service)
        case availability(Service)
        case bookingDetail(bookingId: Int)
    }

    var selectedTab: Tab = .services
    var servicesPath: [Route] = []
    var bookingsPath: [Route] = []
    weak var app: AppCoordinator?

    private let factory: ClientSceneFactory

    init(factory: ClientSceneFactory) {
        self.factory = factory
    }

    func reset() {
        selectedTab = .services
        servicesPath.removeAll()
        bookingsPath.removeAll()
    }

    func popToServicesRoot() {
        selectedTab = .services
        servicesPath.removeAll()
    }

    @ViewBuilder
    func makeServicesRoot() -> some View {
        factory.makeServiceList(coordinator: self)
    }

    @ViewBuilder
    func makeBookingsRoot() -> some View {
        factory.makeBookingList(coordinator: self)
    }

    @ViewBuilder
    func makeProfileRoot() -> some View {
        factory.makeProfile(coordinator: self)
    }

    @ViewBuilder
    func makeDestination(for route: Route) -> some View {
        switch route {
        case .serviceDetail(let service):
            factory.makeServiceDetail(service: service, coordinator: self)
                .toolbar(.hidden, for: .tabBar)
        case .availability(let service):
            factory.makeAvailability(service: service, coordinator: self)
                .toolbar(.hidden, for: .tabBar)
        case .bookingDetail(let bookingId):
            factory.makeBookingDetail(bookingId: bookingId, coordinator: self)
                .toolbar(.hidden, for: .tabBar)
        }
    }
}

extension ClientCoordinator: ServiceListOutput {
    func openService(_ service: Service) {
        servicesPath.append(.serviceDetail(service))
    }
}

extension ClientCoordinator: ServiceDetailOutput {
    func openAvailability(_ service: Service) {
        servicesPath.append(.availability(service))
    }

    func closeServiceDetail() {
        if !servicesPath.isEmpty { servicesPath.removeLast() }
    }
}

extension ClientCoordinator: AvailabilityOutput {
    func bookingCreated() {
        popToServicesRoot()
    }

    func closeAvailability() {
        if !servicesPath.isEmpty { servicesPath.removeLast() }
    }
}

extension ClientCoordinator: BookingListOutput {
    func openBooking(id: Int) {
        bookingsPath.append(.bookingDetail(bookingId: id))
    }
}

extension ClientCoordinator: BookingDetailOutput {
    func closeBookingDetail() {
        if !bookingsPath.isEmpty { bookingsPath.removeLast() }
    }
}

extension ClientCoordinator: ProfileOutput {
    func logoutRequested() {
        app?.logout()
    }

    func themeChanged(_ mode: ThemeMode) {
        app?.themeMode = mode
    }
}

import SwiftUI
import Observation

enum ServiceFormMode: Hashable, Sendable {
    case create
    case edit(serviceId: Int)
}

@MainActor
@Observable
final class AdminCoordinator {
    enum Tab: Hashable {
        case services
        case bookings
        case profile
    }

    enum Route: Hashable {
        case serviceForm(ServiceFormMode)
        case bookingDetail(bookingId: Int)
        case mapPicker
    }

    var selectedTab: Tab = .services
    var servicesPath: [Route] = []
    var bookingsPath: [Route] = []
    var servicesRefreshTrigger = 0
    var mapPickerInitialLatitude: Double?
    var mapPickerInitialLongitude: Double?
    var onMapPicked: ((String, String) -> Void)?
    weak var app: AppCoordinator?

    private let factory: AdminSceneFactory

    init(factory: AdminSceneFactory) {
        self.factory = factory
    }

    func reset() {
        selectedTab = .services
        servicesPath.removeAll()
        bookingsPath.removeAll()
        mapPickerInitialLatitude = nil
        mapPickerInitialLongitude = nil
        onMapPicked = nil
    }

    @ViewBuilder
    func makeServicesRoot() -> some View {
        factory.makeServiceList(coordinator: self)
    }

    @ViewBuilder
    func makeBookingsRoot() -> some View {
        factory.makeBookings(coordinator: self)
    }

    @ViewBuilder
    func makeProfileRoot() -> some View {
        factory.makeProfile(coordinator: self)
    }

    @ViewBuilder
    func makeDestination(for route: Route) -> some View {
        switch route {
        case .serviceForm(let mode):
            factory.makeServiceForm(mode: mode, coordinator: self)
                .toolbar(.hidden, for: .tabBar)
        case .bookingDetail(let bookingId):
            factory.makeBookingDetail(bookingId: bookingId, coordinator: self)
                .toolbar(.hidden, for: .tabBar)
        case .mapPicker:
            factory.makeMapPicker(coordinator: self)
                .toolbar(.hidden, for: .tabBar)
        }
    }
}

extension AdminCoordinator: AdminServiceListOutput {
    func createServiceRequested() {
        servicesPath.append(.serviceForm(.create))
    }
}

extension AdminCoordinator: ServiceFormOutput {
    func serviceSaved() {
        if !servicesPath.isEmpty { servicesPath.removeLast() }
        servicesRefreshTrigger += 1
    }

    func openMapPicker(latitudeText: String, longitudeText: String, onPick: @escaping (String, String) -> Void) {
        mapPickerInitialLatitude = Double(latitudeText)
        mapPickerInitialLongitude = Double(longitudeText)
        onMapPicked = onPick
        servicesPath.append(.mapPicker)
    }
}

extension AdminCoordinator: AdminBookingsOutput {
    func openBooking(id: Int) {
        bookingsPath.append(.bookingDetail(bookingId: id))
    }
}

extension AdminCoordinator: MapPickerOutput {
    func pickConfirmed(latitude: String, longitude: String) {
        let callback = onMapPicked
        closeMapPicker()
        callback?(latitude, longitude)
    }

    func closeMapPicker() {
        onMapPicked = nil
        if !servicesPath.isEmpty { servicesPath.removeLast() }
    }
}

extension AdminCoordinator: BookingDetailOutput {
    func closeBookingDetail() {
        if !bookingsPath.isEmpty { bookingsPath.removeLast() }
    }
}

extension AdminCoordinator: ProfileOutput {
    func logoutRequested() {
        app?.logout()
    }

    func themeChanged(_ mode: ThemeMode) {
        app?.themeMode = mode
    }
}

import SwiftUI

struct AdminSceneFactory {
    let container: DIContainer

    func makeServiceListViewModel(coordinator: AdminCoordinator) -> AdminServiceListViewModel {
        AdminServiceListViewModel(
            getServices: container.makeGetServices(),
            deleteService: container.makeDeleteService(),
            output: coordinator
        )
    }

    func makeServiceList(coordinator: AdminCoordinator) -> AdminServiceListRoot {
        AdminServiceListRoot(factory: self, coordinator: coordinator)
    }

    func makeServiceFormViewModel(mode: ServiceFormMode, coordinator: AdminCoordinator) -> ServiceFormViewModel {
        ServiceFormViewModel(
            mode: mode,
            getServiceById: container.makeGetServiceById(),
            createService: container.makeCreateService(),
            updateService: container.makeUpdateService(),
            output: coordinator
        )
    }

    func makeServiceForm(mode: ServiceFormMode, coordinator: AdminCoordinator) -> AdminServiceFormRoot {
        AdminServiceFormRoot(mode: mode, factory: self, coordinator: coordinator)
    }

    func makeBookings(coordinator: AdminCoordinator) -> AdminBookingsView {
        AdminBookingsView(
            viewModel: AdminBookingsViewModel(
                getBookings: container.makeGetBookings(),
                getServiceNames: container.makeGetServiceNames(),
                output: coordinator
            ),
            coordinator: coordinator
        )
    }

    func makeBookingDetail(bookingId: Int, coordinator: AdminCoordinator) -> BookingDetailView {
        BookingDetailView(
            viewModel: BookingDetailViewModel(
                bookingId: bookingId,
                getBookings: container.makeGetBookings(),
                getServiceById: container.makeGetServiceById(),
                cancelBooking: container.makeCancelBooking(),
                output: coordinator
            )
        )
    }

    func makeMapPicker(coordinator: AdminCoordinator) -> MapPickerView {
        MapPickerView(
            viewModel: MapPickerViewModel(
                latitude: coordinator.mapPickerInitialLatitude,
                longitude: coordinator.mapPickerInitialLongitude,
                output: coordinator
            )
        )
    }

    func makeProfile(coordinator: AdminCoordinator) -> ProfileView {
        ProfileView(
            viewModel: ProfileViewModel(
                getCurrentUser: container.makeGetCurrentUser(),
                preferences: container.preferences,
                output: coordinator
            )
        )
    }
}

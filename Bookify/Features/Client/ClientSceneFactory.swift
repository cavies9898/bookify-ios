import SwiftUI

struct ClientSceneFactory {
    let container: DIContainer

    func makeServiceList(coordinator: ClientCoordinator) -> ServiceListView {
        ServiceListView(
            viewModel: ServiceListViewModel(
                getServices: container.makeGetServices(),
                output: coordinator
            ),
            coordinator: coordinator
        )
    }

    func makeServiceDetail(service: Service, coordinator: ClientCoordinator) -> ServiceDetailView {
        ServiceDetailView(
            viewModel: ServiceDetailViewModel(service: service, output: coordinator)
        )
    }

    func makeAvailability(service: Service, coordinator: ClientCoordinator) -> AvailabilityView {
        AvailabilityView(
            viewModel: AvailabilityViewModel(
                service: service,
                getServiceAvailability: container.makeGetServiceAvailability(),
                output: coordinator
            ),
            createBookingViewModel: CreateBookingViewModel(
                service: service,
                createBooking: container.makeCreateBooking(),
                output: coordinator
            )
        )
    }

    func makeBookingList(coordinator: ClientCoordinator) -> BookingListView {
        BookingListView(
            viewModel: BookingListViewModel(
                getBookings: container.makeGetBookings(),
                getServiceNames: container.makeGetServiceNames(),
                output: coordinator
            ),
            coordinator: coordinator
        )
    }

    func makeBookingDetail(bookingId: Int, coordinator: ClientCoordinator) -> BookingDetailView {
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

    func makeProfile(coordinator: ClientCoordinator) -> ProfileView {
        ProfileView(
            viewModel: ProfileViewModel(
                getCurrentUser: container.makeGetCurrentUser(),
                preferences: container.preferences,
                output: coordinator
            )
        )
    }
}

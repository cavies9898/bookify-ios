import Foundation
import Observation

@MainActor
protocol AdminBookingsOutput: AnyObject {
    func openBooking(id: Int)
}

@MainActor
@Observable
final class AdminBookingsViewModel {
    enum BookingFilter: CaseIterable, Hashable {
        case all
        case pending
        case confirmed
        case cancelled

        var label: String {
            switch self {
            case .all: "Todos"
            case .pending: "Pendiente"
            case .confirmed: "Confirmada"
            case .cancelled: "Cancelada"
            }
        }

        var status: BookingStatus? {
            switch self {
            case .all: nil
            case .pending: .pending
            case .confirmed: .confirmed
            case .cancelled: .cancelled
            }
        }
    }

    struct UiState {
        var filter: BookingFilter = .all
        var bookings: [Booking] = []
        var serviceNames: [Int: String] = [:]
        var isLoading = false
        var errorMessage: String?
        var hasLoaded = false
    }

    var state = UiState()
    private let getBookings: GetBookings
    private let getServiceNames: GetServiceNames
    weak var output: AdminBookingsOutput?

    init(getBookings: GetBookings, getServiceNames: GetServiceNames, output: AdminBookingsOutput) {
        self.getBookings = getBookings
        self.getServiceNames = getServiceNames
        self.output = output
    }

    func loadInitial() async {
        guard !state.hasLoaded else { return }
        state.isLoading = true
        state.serviceNames = await getServiceNames()
        state.hasLoaded = true
        await loadPage()
    }

    func changeFilter(_ filter: BookingFilter) async {
        state.filter = filter
        await loadPage()
    }

    func refresh() async {
        await loadPage()
    }

    func reloadIfReturning() async {
        guard state.hasLoaded else { return }
        await loadPage()
    }

    func openBooking(_ booking: Booking) {
        output?.openBooking(id: booking.id)
    }

    func serviceTitle(for booking: Booking) -> String {
        booking.serviceName ?? state.serviceNames[booking.serviceId] ?? "Servicio \(booking.serviceId)"
    }

    private func loadPage() async {
        state.isLoading = true
        let result = await getBookings(page: 0, size: 10, status: state.filter.status)
        state.isLoading = false
        switch result {
        case .success(let page):
            state.bookings = page.content
            state.errorMessage = nil
        case .failure(let error):
            state.errorMessage = error.message ?? "Error del servidor"
        }
    }
}

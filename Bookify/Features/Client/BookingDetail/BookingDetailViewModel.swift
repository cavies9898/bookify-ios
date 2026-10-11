import Foundation
import Observation
import EventKit

@MainActor
protocol BookingDetailOutput: AnyObject {
    func closeBookingDetail()
}

@MainActor
@Observable
final class BookingDetailViewModel {
    struct UiState {
        var isLoading = true
        var booking: Booking?
        var service: Service?
        var errorMessage: String?
        var showCancelDialog: Bool = false
        var calendarMessage: String?
    }

    var state = UiState()
    private let bookingId: Int
    private let getBookings: GetBookings
    private let getServiceById: GetServiceById
    private let cancelBooking: CancelBooking
    private var hasLoaded = false
    weak var output: BookingDetailOutput?

    init(
        bookingId: Int,
        getBookings: GetBookings,
        getServiceById: GetServiceById,
        cancelBooking: CancelBooking,
        output: BookingDetailOutput
    ) {
        self.bookingId = bookingId
        self.getBookings = getBookings
        self.getServiceById = getServiceById
        self.cancelBooking = cancelBooking
        self.output = output
    }

    func loadInitial() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await reload()
    }

    func reload() async {
        state.isLoading = true
        let result = await getBookings(page: 0, size: 100)
        switch result {
        case .success(let page):
            guard let booking = page.content.first(where: { $0.id == bookingId }) else {
                state.isLoading = false
                state.booking = nil
                state.errorMessage = "Recurso no encontrado"
                return
            }
            state.booking = booking
            state.errorMessage = nil
            let serviceResult = await getServiceById(id: booking.serviceId)
            if case .success(let service) = serviceResult {
                state.service = service
            }
        case .failure(let error):
            state.errorMessage = error.message ?? "Error del servidor"
        }
        state.isLoading = false
    }

    func requestCancel() {
        state.showCancelDialog = true
    }

    func cancel() async {
        let result = await cancelBooking(id: bookingId)
        if case .success = result {
            await reload()
            output?.closeBookingDetail()
        }
    }

    func addToCalendar() async {
        guard let booking = state.booking else { return }
        let eventStore = EKEventStore()
        do {
            let access = try await eventStore.requestFullAccessToEvents()
            guard access else {
                state.calendarMessage = "No se pudo agregar la reserva al calendario"
                return
            }
            let event = EKEvent(eventStore: eventStore)
            event.title = booking.serviceName ?? "Reserva Bookify"
            event.startDate = parseISO(booking.startAt) ?? Date()
            event.endDate = parseISO(booking.endAt) ?? Date().addingTimeInterval(3600)
            event.calendar = eventStore.defaultCalendarForNewEvents
            try eventStore.save(event, span: .thisEvent)
            state.calendarMessage = "Reserva agregada al calendario"
        } catch {
            state.calendarMessage = "No se pudo agregar la reserva al calendario"
        }
    }

    private func parseISO(_ value: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: value) { return date }
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return plain.date(from: value)
    }
}

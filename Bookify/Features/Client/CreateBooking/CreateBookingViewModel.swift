import Foundation
import Observation

@MainActor
@Observable
final class CreateBookingViewModel {
    struct UiState {
        var isSubmitting = false
        var errorMessage: String?
        var showSuccess = false
        var successMessage: String?
        var registeredEmail: String = ""
    }

    var state = UiState()
    private let service: Service
    private let createBooking: CreateBooking
    weak var output: AvailabilityOutput?

    init(service: Service, createBooking: CreateBooking, output: AvailabilityOutput) {
        self.service = service
        self.createBooking = createBooking
        self.output = output
    }

    func confirm(slot: AvailabilitySlot) async {
        guard !state.isSubmitting else { return }
        state.isSubmitting = true
        let result = await createBooking(serviceId: service.id, startAt: slot.startAt, endAt: slot.endAt)
        state.isSubmitting = false
        switch result {
        case .success:
            state.successMessage = "Se creó la reserva para \(state.registeredEmail)"
            state.showSuccess = true
        case .failure(let error):
            state.errorMessage = error.message ?? "Error del servidor"
        }
    }

    func consumedSuccess() {
        state.showSuccess = false
        output?.bookingCreated()
    }
}

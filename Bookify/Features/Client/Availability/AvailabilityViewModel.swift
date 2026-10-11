import Foundation
import Observation

@MainActor
protocol AvailabilityOutput: AnyObject {
    func bookingCreated()
    func closeAvailability()
}

@MainActor
@Observable
final class AvailabilityViewModel {
    struct UiState {
        var service: Service
        var selectedDate: Date = Date()
        var slots: [AvailabilitySlot] = []
        var isLoading = true
        var errorMessage: String?
        var selectedSlot: AvailabilitySlot?
    }

    var state: UiState
    private let getServiceAvailability: GetServiceAvailability
    private var hasLoaded = false
    weak var output: AvailabilityOutput?

    init(service: Service, getServiceAvailability: GetServiceAvailability, output: AvailabilityOutput) {
        self.state = UiState(service: service)
        self.getServiceAvailability = getServiceAvailability
        self.output = output
    }

    func loadInitial() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await reload()
    }

    func changeDate(_ date: Date) async {
        state.selectedDate = date
        await reload()
    }

    func select(slot: AvailabilitySlot) {
        state.selectedSlot = slot
    }

    func reload() async {
        state.isLoading = true
        let result = await getServiceAvailability(
            serviceId: state.service.id,
            date: BookifyFormat.queryDate(state.selectedDate)
        )
        state.isLoading = false
        switch result {
        case .success(let response):
            state.slots = response.slots
            state.errorMessage = nil
        case .failure(let error):
            state.errorMessage = error.message ?? "Error al cargar disponibilidad"
        }
    }
}

import Foundation
import Observation

@MainActor
protocol ServiceDetailOutput: AnyObject {
    func openAvailability(_ service: Service)
    func closeServiceDetail()
}

@MainActor
@Observable
final class ServiceDetailViewModel {
    struct UiState {
        var service: Service
    }

    var state: UiState
    weak var output: ServiceDetailOutput?

    init(service: Service, output: ServiceDetailOutput) {
        self.state = UiState(service: service)
        self.output = output
    }
}

import Foundation
import Observation
import MapKit

@MainActor
protocol ServiceFormOutput: AnyObject {
    func serviceSaved()
    func openMapPicker(latitudeText: String, longitudeText: String, onPick: @escaping (String, String) -> Void)
}

@MainActor
@Observable
final class ServiceFormViewModel {
    struct UiState {
        var name = ""
        var description = ""
        var durationMinutes = 30
        var capacity = 1
        var priceText = ""
        var openingTime = "09:00"
        var closingTime = "17:00"
        var location = ""
        var latitudeText = ""
        var longitudeText = ""
        var isLoading = false
        var errorMessage: String?
        var hasLoaded = false
        var isEditing = false
    }

    var state = UiState()
    private let mode: ServiceFormMode
    private let getServiceById: GetServiceById
    private let createService: CreateService
    private let updateService: UpdateService
    weak var output: ServiceFormOutput?

    init(mode: ServiceFormMode, getServiceById: GetServiceById, createService: CreateService, updateService: UpdateService, output: ServiceFormOutput) {
        self.mode = mode
        self.getServiceById = getServiceById
        self.createService = createService
        self.updateService = updateService
        self.output = output
        if case .edit = mode {
            state.isEditing = true
        }
    }

    var canSave: Bool {
        !state.isLoading && !state.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var selectedCoordinate: CLLocationCoordinate2D? {
        guard let lat = Double(state.latitudeText),
              let lon = Double(state.longitudeText),
              lat >= -90, lat <= 90,
              lon >= -180, lon <= 180 else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    func loadInitial() async {
        guard !state.hasLoaded else { return }
        state.hasLoaded = true
        state.errorMessage = nil
        guard case .edit(let serviceId) = mode else { return }
        state.isLoading = true
        let result = await getServiceById(id: serviceId)
        state.isLoading = false
        switch result {
        case .success(let service):
            guard let service else {
                state.errorMessage = "Error del servidor"
                return
            }
            state.name = service.name
            state.description = service.description ?? ""
            state.durationMinutes = service.durationMinutes
            state.capacity = service.capacity
            state.location = service.location ?? ""
            state.priceText = service.price == 0.0 ? "" : String(service.price)
            state.openingTime = service.openingTime ?? "09:00"
            state.closingTime = service.closingTime ?? "17:00"
            state.latitudeText = service.latitude.map { String(format: "%.6f", $0) } ?? ""
            state.longitudeText = service.longitude.map { String(format: "%.6f", $0) } ?? ""
        case .failure(let error):
            state.errorMessage = error.message ?? "Error del servidor"
        }
    }

    func openMapPicker() {
        output?.openMapPicker(latitudeText: state.latitudeText, longitudeText: state.longitudeText) { [weak self] latitude, longitude in
            self?.state.latitudeText = latitude
            self?.state.longitudeText = longitude
        }
    }

    func save() async {
        guard canSave else { return }
        let params = ServiceParams(
            name: state.name,
            description: state.description,
            durationMinutes: state.durationMinutes,
            capacity: state.capacity,
            price: Double(state.priceText) ?? 0.0,
            openingTime: state.openingTime,
            closingTime: state.closingTime,
            location: state.location,
            latitude: Double(state.latitudeText),
            longitude: Double(state.longitudeText)
        )
        state.isLoading = true
        state.errorMessage = nil
        let result: AppResult<Service>
        switch mode {
        case .create:
            result = await createService(params: params)
        case .edit(let serviceId):
            result = await updateService(id: serviceId, params: params)
        }
        state.isLoading = false
        switch result {
        case .success:
            output?.serviceSaved()
        case .failure(let error):
            state.errorMessage = error.message ?? "Error del servidor"
        }
    }
}

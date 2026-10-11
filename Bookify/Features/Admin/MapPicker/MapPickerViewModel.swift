import SwiftUI
import Observation
import MapKit
import Foundation

@MainActor
protocol MapPickerOutput: AnyObject {
    func pickConfirmed(latitude: String, longitude: String)
    func closeMapPicker()
}

@MainActor
@Observable
final class MapPickerViewModel {
    struct UiState {
        var latitude: Double
        var longitude: Double
        var hasCustomLocation: Bool
        var cameraPosition: MapCameraPosition
    }

    var state: UiState
    weak var output: MapPickerOutput?

    init(latitude: Double?, longitude: Double?, output: MapPickerOutput) {
        self.output = output
        let initialLatitude = latitude ?? 19.4326
        let initialLongitude = longitude ?? -99.1332
        state = UiState(
            latitude: initialLatitude,
            longitude: initialLongitude,
            hasCustomLocation: latitude != nil && longitude != nil,
            cameraPosition: .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: initialLatitude, longitude: initialLongitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            )
        )
    }

    func move(to coordinate: CLLocationCoordinate2D) {
        state.latitude = coordinate.latitude
        state.longitude = coordinate.longitude
    }

    func confirm() {
        output?.pickConfirmed(
            latitude: String(format: "%.6f", state.latitude),
            longitude: String(format: "%.6f", state.longitude)
        )
    }
}

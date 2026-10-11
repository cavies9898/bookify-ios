import SwiftUI
import Observation
import MapKit
import Foundation

struct MapPickerView: View {
    @Bindable var viewModel: MapPickerViewModel

    private var state: MapPickerViewModel.UiState { viewModel.state }

    var body: some View {
        VStack(spacing: 0) {
            MapReader { proxy in
                Map(position: $viewModel.state.cameraPosition) {
                    Annotation(
                        "Ubicación",
                        coordinate: CLLocationCoordinate2D(latitude: state.latitude, longitude: state.longitude)
                    ) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                    }
                }
                .onTapGesture { point in
                    if let coordinate = proxy.convert(point, from: .local) {
                        viewModel.move(to: coordinate)
                    }
                }
            }
            VStack(spacing: 16) {
                Text(String(format: "%.6f, %.6f", state.latitude, state.longitude))
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
                PrimaryButton(title: "Usar esta ubicación") {
                    viewModel.confirm()
                }
            }
            .padding()
        }
        .navigationTitle("Seleccionar ubicación")
        .navigationBarTitleDisplayMode(.inline)
    }
}

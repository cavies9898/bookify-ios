import SwiftUI
import Observation
import UIKit

struct ServiceDetailView: View {
    @Bindable var viewModel: ServiceDetailViewModel

    private var state: ServiceDetailViewModel.UiState { viewModel.state }
    private var service: Service { state.service }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(service.name)
                    .font(.title2)
                    .fontWeight(.bold)
                if let description = service.description, !description.isEmpty {
                    Text(description)
                        .foregroundStyle(.secondary)
                }
                infoRow(title: "Precio", value: BookifyFormat.price(service.price))
                infoRow(title: "Duración", value: BookifyFormat.minutes(service.durationMinutes))
                infoRow(title: "Capacidad", value: BookifyFormat.people(service.capacity))
                if let horario = BookifyFormat.timeRange(opening: service.openingTime, closing: service.closingTime) {
                    infoRow(title: "Horario", value: horario)
                }
                if let location = service.location, !location.isEmpty {
                    infoRow(title: "Ubicación", value: location)
                }
                PrimaryButton(title: "Ver disponibilidad") {
                    viewModel.output?.openAvailability(service)
                }
            }
            .padding()
        }
        .navigationTitle(service.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer(minLength: 8)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
    }
}

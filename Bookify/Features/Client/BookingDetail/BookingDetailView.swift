import SwiftUI
import Observation
import MapKit
import UIKit

struct BookingDetailView: View {
    @Bindable var viewModel: BookingDetailViewModel

    private var state: BookingDetailViewModel.UiState { viewModel.state }

    var body: some View {
        Group {
            if state.isLoading {
                LoadingView()
            } else if let booking = state.booking {
                content(booking)
            } else {
                ErrorStateView(
                    message: state.errorMessage ?? "Error del servidor",
                    onRetry: { Task { await viewModel.reload() } }
                )
            }
        }
        .task { await viewModel.loadInitial() }
        .navigationTitle(state.booking?.serviceName ?? "Reserva")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "¿Cancelar esta reserva?",
            isPresented: $viewModel.state.showCancelDialog
        ) {
            Button("Sí, cancelar", role: .destructive) {
                Task { await viewModel.cancel() }
            }
            Button("No", role: .cancel) {}
        }
        .alert(
            "Calendario",
            isPresented: Binding(
                get: { viewModel.state.calendarMessage != nil },
                set: { if !$0 { viewModel.state.calendarMessage = nil } }
            )
        ) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text(state.calendarMessage ?? "")
        }
    }

    @ViewBuilder
    private func content(_ booking: Booking) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Text(booking.serviceName ?? "Reserva")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer(minLength: 8)
                    StatusBadge(status: booking.status)
                }
                Text(BookifyFormat.dateRange(start: booking.startAt, end: booking.endAt))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let price = booking.servicePrice {
                    infoRow(title: "Precio", value: BookifyFormat.price(price))
                }
                if let name = booking.userName, !name.isEmpty {
                    infoRow(title: "Nombre", value: name)
                }
                if let email = booking.userEmail, !email.isEmpty {
                    infoRow(title: "Correo", value: email)
                }
                locationSection(service: state.service)
                PrimaryButton(title: "Agregar al calendario") {
                    Task { await viewModel.addToCalendar() }
                }
                if booking.status == .confirmed {
                    Button("Cancelar reserva", role: .destructive) {
                        viewModel.requestCancel()
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.statusCancelled)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func locationSection(service: Service?) -> some View {
        if let service, let latitude = service.latitude, let longitude = service.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            Map(position: .constant(.region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )))) {
                Marker(service.name, coordinate: coordinate)
                    .tint(Color.accentColor)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
            .allowsHitTesting(false)
        } else if let service, let location = service.location, !location.isEmpty {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(Color.accentColor)
                Text(location)
                    .font(.subheadline)
                Spacer(minLength: 8)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
        }
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

import SwiftUI
import Observation
import UIKit

struct AvailabilityView: View {
    @Bindable var viewModel: AvailabilityViewModel
    @Bindable var createBookingViewModel: CreateBookingViewModel

    private var state: AvailabilityViewModel.UiState { viewModel.state }

    var body: some View {
        let selectedSlot = state.selectedSlot
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if createBookingViewModel.state.isSubmitting {
                    CreateBookingView(viewModel: createBookingViewModel)
                }
                DatePicker("Fecha", selection: $viewModel.state.selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                slotsContent
            }
            .padding()
        }
        .task { await viewModel.loadInitial() }
        .onChange(of: viewModel.state.selectedDate) { date in
            Task { await viewModel.changeDate(date) }
        }
        .confirmationDialog(
            "Reservar \(viewModel.state.service.name)",
            isPresented: Binding(
                get: { viewModel.state.selectedSlot != nil },
                set: { if !$0 { viewModel.state.selectedSlot = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Confirmar") {
                if let slot = viewModel.state.selectedSlot ?? selectedSlot {
                    Task { await createBookingViewModel.confirm(slot: slot) }
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text((viewModel.state.selectedSlot ?? selectedSlot).map { BookifyFormat.dateRange(start: $0.startAt, end: $0.endAt) } ?? "")
        }
        .alert(
            "Reserva creada",
            isPresented: $createBookingViewModel.state.showSuccess
        ) {
            Button("Aceptar") {
                createBookingViewModel.consumedSuccess()
            }
        } message: {
            Text(createBookingViewModel.state.successMessage ?? "")
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { createBookingViewModel.state.errorMessage != nil },
                set: { if !$0 { createBookingViewModel.state.errorMessage = nil } }
            )
        ) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text(createBookingViewModel.state.errorMessage ?? "")
        }
        .navigationTitle(viewModel.state.service.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var slotsContent: some View {
        if state.isLoading {
            LoadingView()
        } else if state.errorMessage != nil {
            ErrorStateView(
                message: state.errorMessage ?? "Error al cargar disponibilidad",
                onRetry: { Task { await viewModel.reload() } }
            )
        } else if state.slots.isEmpty {
            ContentUnavailableView("No hay horarios disponibles", systemImage: "clock")
        } else {
            VStack(spacing: 10) {
                ForEach(state.slots) { slot in
                    slotRow(slot)
                }
            }
        }
    }

    @ViewBuilder
    private func slotRow(_ slot: AvailabilitySlot) -> some View {
        if slot.available {
            Button {
                viewModel.select(slot: slot)
            } label: {
                slotText(slot)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: Color.slotGradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
            }
        } else {
            slotText(slot)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .foregroundStyle(.secondary)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
                .disabled(true)
        }
    }

    private func slotText(_ slot: AvailabilitySlot) -> some View {
        Text("\(BookifyFormat.time(slot.startAt)) - \(BookifyFormat.time(slot.endAt))")
            .fontWeight(.medium)
    }
}

import SwiftUI
import Observation
import UIKit

struct AdminServiceListView: View {
    @Bindable var viewModel: AdminServiceListViewModel
    let coordinator: AdminCoordinator

    private var state: AdminServiceListViewModel.UiState { viewModel.state }

    var body: some View {
        content
            .task { await viewModel.loadInitial() }
            .overlay(alignment: .bottomTrailing) { createButton }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { viewModel.state.deleteErrorMessage != nil },
                    set: { if !$0 { viewModel.state.deleteErrorMessage = nil } }
                )
            ) {
                Button("Aceptar", role: .cancel) {}
            } message: {
                Text(state.deleteErrorMessage ?? "")
            }
            .onChange(of: coordinator.servicesRefreshTrigger) {
                Task { await viewModel.refresh() }
            }
    }

    @ViewBuilder
    private var content: some View {
        if state.isLoading && state.services.isEmpty {
            LoadingView()
        } else if state.hasLoaded && state.services.isEmpty {
            if state.errorMessage != nil {
                ErrorStateView(
                    message: state.errorMessage ?? "Error al cargar servicios",
                    onRetry: { Task { await viewModel.refresh() } }
                )
            } else {
                ContentUnavailableView("No hay servicios disponibles", systemImage: "square.grid.2x2")
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(state.services) { service in
                        serviceRow(service)
                    }
                }
                .padding()
            }
            .refreshable { await viewModel.refresh() }
        }
    }

    private func serviceRow(_ service: Service) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(service.name)
                    .font(.headline)
                Text("\(BookifyFormat.minutes(service.durationMinutes)) · \(BookifyFormat.people(service.capacity))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            Text(BookifyFormat.price(service.price))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.accentColor)
            Button {
                Task { await viewModel.delete(service) }
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
    }

    private var createButton: some View {
        Button {
            viewModel.create()
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(radius: 6, y: 3)
        }
        .padding(20)
    }
}

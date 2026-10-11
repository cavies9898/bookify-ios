import SwiftUI
import Observation
import UIKit

struct ServiceListView: View {
    @Bindable var viewModel: ServiceListViewModel
    let coordinator: ClientCoordinator

    private var state: ServiceListViewModel.UiState { viewModel.state }

    var body: some View {
        content
            .task { await viewModel.loadInitial() }
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
                        Button {
                            viewModel.output?.openService(service)
                        } label: {
                            serviceRow(service)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if let index = state.services.firstIndex(of: service) {
                                viewModel.loadMoreIfNeeded(index: index)
                            }
                        }
                    }
                }
                .padding()
            }
            .refreshable { await viewModel.refresh() }
        }
    }

    private func serviceRow(_ service: Service) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(service.name)
                    .font(.headline)
                Spacer(minLength: 8)
                Text(BookifyFormat.price(service.price))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentColor)
            }
            Text("\(BookifyFormat.minutes(service.durationMinutes)) · \(BookifyFormat.people(service.capacity))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let location = service.location, !location.isEmpty {
                Text(location)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let horario = BookifyFormat.timeRange(opening: service.openingTime, closing: service.closingTime) {
                Text(horario)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
    }
}

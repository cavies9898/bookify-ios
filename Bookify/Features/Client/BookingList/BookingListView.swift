import SwiftUI
import Observation
import UIKit

struct BookingListView: View {
    @Bindable var viewModel: BookingListViewModel
    let coordinator: ClientCoordinator

    private var state: BookingListViewModel.UiState { viewModel.state }

    var body: some View {
        VStack(spacing: 0) {
            filterRow
            Divider()
            content
        }
        .task { await viewModel.loadInitial() }
        .onChange(of: coordinator.bookingsPath.isEmpty) { if $0 { Task { await viewModel.reloadIfNotEmptyPath() } } }
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(BookingListViewModel.BookingFilter.allCases, id: \.self) { filter in
                    FilterChip(title: filter.label, isSelected: state.filter == filter) {
                        Task { await viewModel.changeFilter(filter) }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    @ViewBuilder
    private var content: some View {
        if state.isLoading && state.bookings.isEmpty {
            LoadingView()
        } else if state.hasLoaded && state.bookings.isEmpty {
            if state.errorMessage != nil {
                ErrorStateView(
                    message: state.errorMessage ?? "Error del servidor",
                    onRetry: { Task { await viewModel.refresh() } }
                )
            } else {
                ContentUnavailableView("No hay reservas", systemImage: "calendar")
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(state.bookings) { booking in
                        Button {
                            viewModel.output?.openBooking(id: booking.id)
                        } label: {
                            BookingRowView(
                                booking: booking,
                                title: viewModel.serviceTitle(for: booking)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .refreshable { await viewModel.refresh() }
        }
    }
}

struct BookingRowView: View {
    let booking: Booking
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(BookifyFormat.dateRange(start: booking.startAt, end: booking.endAt))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            StatusBadge(status: booking.status)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
    }
}

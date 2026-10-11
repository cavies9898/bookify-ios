import Foundation

struct GetBookings {
    private let bookings: BookingRepository

    init(bookings: BookingRepository) {
        self.bookings = bookings
    }

    func callAsFunction(page: Int, size: Int = 10, status: BookingStatus? = nil) async -> AppResult<PaginatedResponse<Booking>> {
        await .catching {
            try await bookings.fetchBookings(page: page, size: size, status: status)
        }
    }
}

import Foundation

struct CreateBooking {
    private let bookings: BookingRepository

    init(bookings: BookingRepository) {
        self.bookings = bookings
    }

    func callAsFunction(serviceId: Int, startAt: String, endAt: String) async -> AppResult<Booking> {
        await .catching {
            try await bookings.create(serviceId: serviceId, startAt: startAt, endAt: endAt)
        }
    }
}

struct CancelBooking {
    private let bookings: BookingRepository

    init(bookings: BookingRepository) {
        self.bookings = bookings
    }

    func callAsFunction(id: Int) async -> AppResult<Void> {
        await .catching {
            try await bookings.delete(id: id)
        }
    }
}

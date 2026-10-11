import Foundation

struct BookingDTO: Decodable {
    let id: Int?
    let serviceId: Int?
    let service: ServiceRefDTO?
    let startAt: String?
    let endAt: String?
    let status: String?
    let createdAt: String?
    let updatedAt: String?
    let userName: String?
    let userEmail: String?

    struct ServiceRefDTO: Decodable {
        let id: Int?
        let name: String?
        let price: Double?
    }

    var domain: Booking {
        Booking(
            id: id ?? 0,
            userId: nil,
            serviceId: service?.id ?? serviceId ?? 0,
            serviceName: service?.name,
            servicePrice: service?.price,
            startAt: startAt ?? "",
            endAt: endAt ?? "",
            status: status.flatMap(BookingStatus.init(rawValue:)) ?? .pending,
            createdAt: createdAt,
            updatedAt: updatedAt,
            userName: userName,
            userEmail: userEmail
        )
    }
}

struct BookingCreateDTO: Encodable {
    let serviceId: Int
    let startAt: String
    let endAt: String
}

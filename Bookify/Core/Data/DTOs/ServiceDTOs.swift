import Foundation

struct ServiceDTO: Decodable {
    let id: Int?
    let name: String?
    let description: String?
    let durationMinutes: Int?
    let capacity: Int?
    let price: Double?
    let openingTime: String?
    let closingTime: String?
    let location: String?
    let latitude: Double?
    let longitude: Double?
    let active: Bool?
    let createdAt: String?
    let updatedAt: String?

    var domain: Service {
        Service(
            id: id ?? 0,
            name: name ?? "",
            description: description,
            durationMinutes: durationMinutes ?? 0,
            capacity: capacity ?? 0,
            price: price ?? 0,
            openingTime: openingTime,
            closingTime: closingTime,
            location: location,
            latitude: latitude,
            longitude: longitude,
            active: active,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

struct ServiceParamsDTO: Encodable {
    let name: String
    let description: String
    let durationMinutes: Int
    let capacity: Int
    let price: Double
    let openingTime: String
    let closingTime: String
    let location: String
    let latitude: Double?
    let longitude: Double?
}

extension ServiceParams {
    var dto: ServiceParamsDTO {
        ServiceParamsDTO(
            name: name,
            description: description,
            durationMinutes: durationMinutes,
            capacity: capacity,
            price: price,
            openingTime: openingTime,
            closingTime: closingTime,
            location: location,
            latitude: latitude,
            longitude: longitude
        )
    }
}

struct AvailabilityDTO: Decodable {
    let serviceId: Int?
    let date: String?
    let slots: [SlotDTO]?

    struct SlotDTO: Decodable {
        let startAt: String?
        let endAt: String?
        let available: Bool?
    }

    var domain: AvailabilityResponse {
        AvailabilityResponse(
            serviceId: serviceId ?? 0,
            date: date ?? "",
            slots: (slots ?? []).compactMap { slot in
                guard let startAt = slot.startAt, let endAt = slot.endAt else { return nil }
                return AvailabilitySlot(startAt: startAt, endAt: endAt, available: slot.available ?? false)
            }
        )
    }
}

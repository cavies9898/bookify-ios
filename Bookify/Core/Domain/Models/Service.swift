import Foundation

struct Service: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let description: String?
    let durationMinutes: Int
    let capacity: Int
    let price: Double
    let openingTime: String?
    let closingTime: String?
    let location: String?
    let latitude: Double?
    let longitude: Double?
    let active: Bool?
    let createdAt: String?
    let updatedAt: String?
}

struct ServiceParams: Hashable, Sendable {
    var name: String
    var description: String
    var durationMinutes: Int
    var capacity: Int
    var price: Double
    var openingTime: String
    var closingTime: String
    var location: String
    var latitude: Double?
    var longitude: Double?
}

struct AvailabilitySlot: Identifiable, Hashable, Sendable {
    let startAt: String
    let endAt: String
    let available: Bool

    var id: String { startAt }
}

struct AvailabilityResponse: Hashable, Sendable {
    let serviceId: Int
    let date: String
    let slots: [AvailabilitySlot]
}

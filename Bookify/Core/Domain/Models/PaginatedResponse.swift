import Foundation

struct PaginatedResponse<T: Sendable>: Sendable {
    let content: [T]
    let totalElements: Int
    let totalPages: Int
    let last: Bool
    let pageNumber: Int
    let pageSize: Int
}

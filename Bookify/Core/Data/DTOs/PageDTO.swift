import Foundation

struct PageDTO<T: Decodable>: Decodable {
    let content: [T]?
    let totalElements: Int?
    let totalPages: Int?
    let last: Bool?
    let pageNumber: Int?
    let pageSize: Int?
    let pageable: PageableDTO?

    struct PageableDTO: Decodable {
        let pageNumber: Int?
        let pageSize: Int?
    }

    func mapped<M>(_ transform: (T) -> M) -> PaginatedResponse<M> {
        PaginatedResponse(
            content: (content ?? []).map(transform),
            totalElements: totalElements ?? 0,
            totalPages: totalPages ?? 0,
            last: last ?? true,
            pageNumber: pageNumber ?? pageable?.pageNumber ?? 0,
            pageSize: pageSize ?? pageable?.pageSize ?? 0
        )
    }
}

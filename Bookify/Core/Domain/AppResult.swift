import Foundation

typealias AppResult<T> = Result<T, AppError>

extension Result where Failure == AppError {
    static func catching(_ operation: () async throws -> Success) async -> Result<Success, AppError> {
        do {
            return .success(try await operation())
        } catch let error as AppError {
            return .failure(error)
        } catch {
            return .failure(.unknown)
        }
    }
}

import Foundation

@MainActor
final class DIContainer {
    let session: SessionStore
    let preferences: PreferencesStore
    private let client: HTTPClient

    init(session: SessionStore, preferences: PreferencesStore, client: HTTPClient) {
        self.session = session
        self.preferences = preferences
        self.client = client
    }

    static func makeDefault() -> DIContainer {
        let session = KeychainSessionStore(keychain: KeychainStore())
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        let apiClient = APIClient(
            baseURL: AppConfig.baseURL,
            session: URLSession(configuration: configuration),
            sessionStore: session
        )
        return DIContainer(
            session: session,
            preferences: UserDefaultsPreferences(),
            client: apiClient
        )
    }

    func makeAuthRepository() -> AuthRepository {
        RemoteAuthRepository(client: client)
    }

    func makeServiceRepository() -> ServiceRepository {
        RemoteServiceRepository(client: client)
    }

    func makeBookingRepository() -> BookingRepository {
        RemoteBookingRepository(client: client)
    }

    func makeLogin() -> Login {
        Login(auth: makeAuthRepository(), session: session)
    }

    func makeRegister() -> Register {
        Register(auth: makeAuthRepository(), session: session)
    }

    func makeForgotPassword() -> ForgotPassword {
        ForgotPassword(auth: makeAuthRepository())
    }

    func makeResetPassword() -> ResetPassword {
        ResetPassword(auth: makeAuthRepository())
    }

    func makeLogout() -> Logout {
        Logout(auth: makeAuthRepository(), session: session)
    }

    func makeGetCurrentUser() -> GetCurrentUser {
        GetCurrentUser(session: session)
    }

    func makeGetServices() -> GetServices {
        GetServices(services: makeServiceRepository())
    }

    func makeGetServiceAvailability() -> GetServiceAvailability {
        GetServiceAvailability(services: makeServiceRepository())
    }

    func makeGetServiceById() -> GetServiceById {
        GetServiceById(services: makeServiceRepository())
    }

    func makeGetServiceNames() -> GetServiceNames {
        GetServiceNames(services: makeServiceRepository())
    }

    func makeCreateService() -> CreateService {
        CreateService(services: makeServiceRepository())
    }

    func makeUpdateService() -> UpdateService {
        UpdateService(services: makeServiceRepository())
    }

    func makeDeleteService() -> DeleteService {
        DeleteService(services: makeServiceRepository())
    }

    func makeGetBookings() -> GetBookings {
        GetBookings(bookings: makeBookingRepository())
    }

    func makeCreateBooking() -> CreateBooking {
        CreateBooking(bookings: makeBookingRepository())
    }

    func makeCancelBooking() -> CancelBooking {
        CancelBooking(bookings: makeBookingRepository())
    }
}

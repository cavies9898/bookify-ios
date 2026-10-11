import Testing
@testable import Bookify

@MainActor
private final class FakeSessionStore: SessionStore {
    var accessToken: String?
    var refreshToken: String?
    var storedUser: User?
    var logoutCalled = false

    var isLoggedIn: Bool { accessToken != nil }
    var currentUser: User? { storedUser }

    func save(_ auth: AuthResponse) {
        accessToken = auth.accessToken
        refreshToken = auth.refreshToken
        storedUser = auth.user
    }

    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func logout() {
        logoutCalled = true
        accessToken = nil
        refreshToken = nil
        storedUser = nil
    }
}

@MainActor
private final class FakeAuthRepository: AuthRepository {
    var lastEmail: String?
    var lastPassword: String?
    var loginResult: Result<AuthResponse, Error> = .failure(AppError.unknown)
    var forgotMessage = "mensaje"
    var resetMessage = "restablecido"
    var logoutCalled = false

    func login(email: String, password: String) async throws -> AuthResponse {
        lastEmail = email
        lastPassword = password
        return try loginResult.get()
    }

    func register(name: String, email: String, password: String) async throws -> AuthResponse {
        lastEmail = email
        lastPassword = password
        return try loginResult.get()
    }

    func forgotPassword(email: String) async throws -> String {
        lastEmail = email
        return forgotMessage
    }

    func resetPassword(token: String, newPassword: String) async throws -> String {
        lastEmail = token
        lastPassword = newPassword
        return resetMessage
    }

    func logout() async throws {
        logoutCalled = true
    }
}

@MainActor
private final class FakeServiceRepository: ServiceRepository {
    var stubPage = PaginatedResponse<Service>(
        content: [], totalElements: 0, totalPages: 0, last: true, pageNumber: 0, pageSize: 0
    )
    var stubError: Error?
    var lastRequestedPage: Int?
    var lastRequestedSize: Int?

    func fetchServices(page: Int, size: Int) async throws -> PaginatedResponse<Service> {
        lastRequestedPage = page
        lastRequestedSize = size
        if let stubError { throw stubError }
        return stubPage
    }

    func fetchAvailability(serviceId: Int, date: String) async throws -> AvailabilityResponse {
        AvailabilityResponse(serviceId: serviceId, date: date, slots: [])
    }

    func create(_ params: ServiceParams) async throws -> Service {
        Self.stubService
    }

    func update(id: Int, _ params: ServiceParams) async throws -> Service {
        Self.stubService
    }

    func delete(id: Int) async throws {}

    static let stubService = Service(
        id: 1, name: "Corte", description: nil, durationMinutes: 30, capacity: 2,
        price: 150, openingTime: "09:00", closingTime: "17:00", location: "CDMX",
        latitude: 19.4, longitude: -99.1, active: true, createdAt: nil, updatedAt: nil
    )
}

@MainActor
private final class FakeBookingRepository: BookingRepository {
    var lastStatus: BookingStatus?
    var createCalledWith: (serviceId: Int, startAt: String, endAt: String)?

    func fetchBookings(page: Int, size: Int, status: BookingStatus?) async throws -> PaginatedResponse<Booking> {
        lastStatus = status
        return PaginatedResponse(content: [], totalElements: 0, totalPages: 0, last: true, pageNumber: 0, pageSize: 0)
    }

    func create(serviceId: Int, startAt: String, endAt: String) async throws -> Booking {
        createCalledWith = (serviceId, startAt, endAt)
        return Booking(
            id: 1, userId: nil, serviceId: serviceId, serviceName: nil, servicePrice: nil,
            startAt: startAt, endAt: endAt, status: .pending, createdAt: nil, updatedAt: nil,
            userName: nil, userEmail: nil
        )
    }

    func delete(id: Int) async throws {}
}

@MainActor
private func makeLoginSUT() -> (Login, FakeSessionStore, FakeAuthRepository) {
    let session = FakeSessionStore()
    let repo = FakeAuthRepository()
    return (Login(auth: repo, session: session), session, repo)
}

@MainActor
struct LoginTests {
    @Test func emptyEmailFails() async {
        let (sut, _, _) = makeLoginSUT()
        let result = await sut(email: "   ", password: "123456")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.emptyEmail))
    }

    @Test func emailWithoutAtFails() async {
        let (sut, _, _) = makeLoginSUT()
        let result = await sut(email: "usuarioexample.com", password: "123456")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.invalidEmail))
    }

    @Test func emailWithoutDotFails() async {
        let (sut, _, _) = makeLoginSUT()
        let result = await sut(email: "usuario@ejemplo", password: "123456")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.invalidEmail))
    }

    @Test func emptyPasswordFails() async {
        let (sut, _, _) = makeLoginSUT()
        let result = await sut(email: "a@b.com", password: "")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.emptyPassword))
    }

    @Test func shortPasswordFails() async {
        let (sut, _, _) = makeLoginSUT()
        let result = await sut(email: "a@b.com", password: "12345")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.shortPassword(minimum: 8)))
    }

    @Test func weakPasswordFails() async {
        let (sut, _, _) = makeLoginSUT()
        let result = await sut(email: "a@b.com", password: "12345678")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.weakPassword))
    }

    @Test func successTrimsEmailButNotPassword() async {
        let (sut, session, repo) = makeLoginSUT()
        repo.loginResult = .success(
            AuthResponse(
                accessToken: "acc", refreshToken: "ref", tokenType: "Bearer", expiresIn: 3600,
                user: User(id: 7, name: "Ana", email: "a@b.com", role: .cliente)
            )
        )
        let result = await sut(email: "  a@b.com  ", password: " 1234567a ")
        guard case .success = result else { Issue.record("debe tener éxito"); return }
        #expect(repo.lastEmail == "a@b.com")
        #expect(repo.lastPassword == " 1234567a ")
        #expect(session.isLoggedIn)
        #expect(session.currentUser?.id == 7)
    }
}

@MainActor
struct RegisterTests {
    private func makeSUT() -> (Register, FakeSessionStore, FakeAuthRepository) {
        let session = FakeSessionStore()
        let repo = FakeAuthRepository()
        return (Register(auth: repo, session: session), session, repo)
    }

    @Test func emptyNameFails() async {
        let (sut, _, _) = makeSUT()
        let result = await sut(name: "   ", email: "a@b.com", password: "123456")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.emptyName))
    }

    @Test func shortNameFails() async {
        let (sut, _, _) = makeSUT()
        let result = await sut(name: " A ", email: "a@b.com", password: "123456")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.shortName))
    }

    @Test func invalidEmailFails() async {
        let (sut, _, _) = makeSUT()
        let result = await sut(name: "Ana", email: "sin-arroba", password: "123456")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.invalidEmail))
    }

    @Test func shortPasswordFails() async {
        let (sut, _, _) = makeSUT()
        let result = await sut(name: "Ana", email: "a@b.com", password: "12345")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.shortPassword(minimum: 8)))
    }

    @Test func weakPasswordFails() async {
        let (sut, _, _) = makeSUT()
        let result = await sut(name: "Ana", email: "a@b.com", password: "abcdefgh")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.weakPassword))
    }

    @Test func successTrimsAndSavesSession() async {
        let (sut, session, repo) = makeSUT()
        repo.loginResult = .success(
            AuthResponse(
                accessToken: "acc", refreshToken: "ref", tokenType: "Bearer", expiresIn: nil,
                user: User(id: 1, name: "Ana", email: "a@b.com", role: .admin)
            )
        )
        let result = await sut(name: "  Ana  ", email: " a@b.com ", password: "1234567a")
        guard case .success = result else { Issue.record("debe tener éxito"); return }
        #expect(repo.lastEmail == "a@b.com")
        #expect(session.isLoggedIn)
        #expect(session.currentUser?.role == .admin)
    }
}

@MainActor
struct PasswordRecoveryTests {
    private func makeSUT() -> (ForgotPassword, ResetPassword, FakeAuthRepository) {
        let repo = FakeAuthRepository()
        return (ForgotPassword(auth: repo), ResetPassword(auth: repo), repo)
    }

    @Test func forgotPasswordValidatesEmail() async {
        let (forgot, _, _) = makeSUT()
        let result = await forgot(email: "  ")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.emptyEmail))
    }

    @Test func forgotPasswordReturnsServerMessage() async {
        let (forgot, _, repo) = makeSUT()
        repo.forgotMessage = "Revisa tu correo"
        let result = await forgot(email: " a@b.com ")
        guard case .success(let message) = result else { Issue.record("debe tener éxito"); return }
        #expect(message == "Revisa tu correo")
    }

    @Test func resetRejectsEmptyCode() async {
        let (_, reset, _) = makeSUT()
        let result = await reset(code: "", newPassword: "12345678", confirmPassword: "12345678")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.emptyCode))
    }

    @Test func resetRejectsCodeWithWrongLength() async {
        let (_, reset, _) = makeSUT()
        let result = await reset(code: "12345", newPassword: "12345678", confirmPassword: "12345678")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.invalidCodeLength))
    }

    @Test func resetRejectsEmptyPassword() async {
        let (_, reset, _) = makeSUT()
        let result = await reset(code: "123456", newPassword: "", confirmPassword: "")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.emptyPassword))
    }

    @Test func resetRequiresEightCharacters() async {
        let (_, reset, _) = makeSUT()
        let result = await reset(code: "123456", newPassword: "1234567", confirmPassword: "1234567")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.shortPassword(minimum: 8)))
    }

    @Test func resetRejectsWeakPassword() async {
        let (_, reset, _) = makeSUT()
        let result = await reset(code: "123456", newPassword: "12345678", confirmPassword: "12345678")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.weakPassword))
    }

    @Test func resetRejectsMismatchedPasswords() async {
        let (_, reset, _) = makeSUT()
        let result = await reset(code: "123456", newPassword: "abcdefg1", confirmPassword: "abcdefg2")
        guard case .failure(let error) = result else { Issue.record("debe fallar"); return }
        #expect(error == .validation(.passwordsDoNotMatch))
    }

    @Test func resetDoesNotTrimAndReturnsMessage() async {
        let (_, reset, repo) = makeSUT()
        repo.resetMessage = "Listo"
        let result = await reset(code: "123456", newPassword: " 1234567a ", confirmPassword: " 1234567a ")
        guard case .success(let message) = result else { Issue.record("debe tener éxito"); return }
        #expect(message == "Listo")
        #expect(repo.lastPassword == " 1234567a ")
    }
}

@MainActor
struct SessionTests {
    @Test func logoutRevokesServerAndClearsLocalSession() async {
        let session = FakeSessionStore()
        session.save(
            AuthResponse(
                accessToken: "acc", refreshToken: "ref", tokenType: nil, expiresIn: nil,
                user: User(id: 1, name: "Ana", email: "a@b.com", role: .cliente)
            )
        )
        let repo = FakeAuthRepository()
        let sut = Logout(auth: repo, session: session)
        await sut()
        #expect(repo.logoutCalled)
        #expect(session.logoutCalled)
        #expect(!session.isLoggedIn)
        #expect(session.currentUser == nil)
    }

    @Test func getCurrentUserReturnsStoredUser() {
        let session = FakeSessionStore()
        session.storedUser = User(id: 2, name: "Luis", email: "l@b.com", role: .admin)
        let sut = GetCurrentUser(session: session)
        #expect(sut()?.role == .admin)
    }
}

@MainActor
struct ServiceLookupTests {
    private func makeSUT() -> (GetServiceById, GetServiceNames, FakeServiceRepository) {
        let repo = FakeServiceRepository()
        return (GetServiceById(services: repo), GetServiceNames(services: repo), repo)
    }

    @Test func getByIdScansFirstPageOf100() async {
        let (byId, _, repo) = makeSUT()
        repo.stubPage = PaginatedResponse(
            content: [FakeServiceRepository.stubService],
            totalElements: 1, totalPages: 1, last: true, pageNumber: 0, pageSize: 100
        )
        let result = await byId(id: 1)
        guard case .success(let service) = result else { Issue.record("debe tener éxito"); return }
        #expect(service?.name == "Corte")
        #expect(repo.lastRequestedPage == 0)
        #expect(repo.lastRequestedSize == 100)
    }

    @Test func getByIdReturnsNilWhenMissing() async {
        let (byId, _, _) = makeSUT()
        let result = await byId(id: 99)
        guard case .success(let service) = result else { Issue.record("debe completar"); return }
        #expect(service == nil)
    }

    @Test func serviceNamesMapsIdsAndSurvivesFailure() async {
        let (_, names, repo) = makeSUT()
        repo.stubPage = PaginatedResponse(
            content: [FakeServiceRepository.stubService],
            totalElements: 1, totalPages: 1, last: true, pageNumber: 0, pageSize: 100
        )
        let map = await names()
        #expect(map[1] == "Corte")

        repo.stubError = AppError.status(500)
        let empty = await names()
        #expect(empty.isEmpty)
    }
}

@MainActor
struct BookingTests {
    @Test func getBookingsPassesStatusThroughOrOmitsIt() async {
        let repo = FakeBookingRepository()
        let sut = GetBookings(bookings: repo)
        _ = await sut(page: 0, status: .confirmed)
        #expect(repo.lastStatus == .confirmed)
        _ = await sut(page: 0)
        #expect(repo.lastStatus == nil)
    }

    @Test func createBookingHasNoLocalValidation() async {
        let repo = FakeBookingRepository()
        let sut = CreateBooking(bookings: repo)
        let result = await sut(serviceId: 5, startAt: "", endAt: "")
        guard case .success = result else { Issue.record("debe delegar al servidor"); return }
        #expect(repo.createCalledWith?.serviceId == 5)
    }

    @Test func cancelBookingDelegatesToRepository() async {
        let repo = FakeBookingRepository()
        let sut = CancelBooking(bookings: repo)
        let result = await sut(id: 10)
        guard case .success = result else { Issue.record("debe tener éxito"); return }
    }
}

@MainActor
struct ErrorMappingTests {
    @Test func mapsHttpCodesToSpanishMessages() {
        #expect(ErrorMapper.message(for: 400) == "Solicitud inválida")
        #expect(ErrorMapper.message(for: 401) == "Credenciales incorrectas")
        #expect(ErrorMapper.message(for: 403) == "No tienes permiso")
        #expect(ErrorMapper.message(for: 404) == "Recurso no encontrado")
        #expect(ErrorMapper.message(for: 409) == "Conflicto con el recurso existente")
        #expect(ErrorMapper.message(for: 422) == "Datos inválidos")
        #expect(ErrorMapper.message(for: 500) == "Error interno del servidor")
        #expect(ErrorMapper.message(for: 502) == "Servidor no disponible")
        #expect(ErrorMapper.message(for: 503) == "Servicio no disponible")
        #expect(ErrorMapper.message(for: 418) == "Error del servidor (418)")
    }

    @Test func appErrorMessagesMatchSpec() {
        #expect(AppError.offline.message == "Sin conexión a internet")
        #expect(AppError.timeout.message == "Tiempo de espera agotado")
        #expect(AppError.server.message == "Error del servidor")
        #expect(AppError.unknown.message == nil)
        #expect(AppError.status(409).message == "Conflicto con el recurso existente")
        #expect(AppError.validation(.emptyEmail).message == "El correo electrónico es obligatorio")
    }
}

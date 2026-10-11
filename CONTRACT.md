# Bookify iOS — Contrato de implementación (Features)

Este documento es la fuente de verdad para implementar las features sobre el Core ya escrito.
**NO ejecutar `xcodebuild`** (los tres módulos se compilan juntos al final). Revisar el código manualmente.

## 1. Convenciones

- Swift 5.9+, SwiftUI, iOS 17+. Sin UIKit salvo `WKWebView`/EventKit/MapKit donde se indique.
- El proyecto usa `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` y `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`:
  **cada archivo debe importar lo que usa** (`import SwiftUI`, `import Observation`, `import MapKit`, `import EventKit`…). No heredar imports entre archivos.
- Patrón de pantalla obligatorio:

```swift
import SwiftUI
import Observation

@MainActor
@Observable
final class XViewModel {
    struct UiState {
        var isLoading = false
        var items: [Item] = []
        var errorMessage: String?
    }

    var state = UiState()
    private let dependency: SomeUseCase
    weak var output: XOutput?

    init(dependency: SomeUseCase, output: XOutput) {
        self.dependency = dependency
        self.output = output
    }
}

struct XView: View {
    @Bindable var viewModel: XViewModel
    // init() sintetizado: init(viewModel: XViewModel)
}
```

- Un único `UiState` struct por pantalla (propiedad `state`, settable para poder hacer `$viewModel.state.email`). Eventos one-shot (alertas) como campo del UiState (`var showXAlert = false`, `var alertMessage: String?`); navegación **siempre** vía `output` → coordinador.
- Acciones async desde vistas: `Button { Task { await viewModel.submit() } }`, `.task { await viewModel.loadInitial() }` (con guard `hasLoaded` dentro del VM para cargar solo la primera vez), `.refreshable { await viewModel.refresh() }`, `onChange` async vía `Task { await ... }`.
- `weak var output: ...` — los protocolos de output son `@MainActor ... : AnyObject`.
- **Prohibido**: `NavigationLink`, `@Environment(\.dismiss)`, force-unwrap, ternarios largos, comentarios innecesarios, archivos > ~300 líneas.
- Errores: `switch result { case .success: ...; case .failure(let error): ... }`.
  - Error de campo: `if case .validation(let validation) = error { ... }` → asignar mensaje al campo (`validation.message`).
  - Error general: `state.errorMessage = error.message ?? "<fallback de la vista>"`.
- Botón atrás: **nunca** en la vista raíz de tab; las vistas de detalle se hacen `pop` con `output.closeX()`. El chrome (nav bar con título y back) lo aporta `NavigationStack` nativo; las vistas de detalle solo añaden `.navigationTitle(...)` + `.navigationBarTitleDisplayMode(.inline)`.
- Componentes de `Core/DesignSystem/Components`: `PrimaryButton(title:isLoading:isEnabled:action:)`, `SecondaryButton(title:action:)`, `AppTextField(title:text:placeholder:isSecure:error:keyboard:)`, `LoadingView()`, `ErrorStateView(message:retryTitle:onRetry:)`, `StatusBadge(status:)`, `FilterChip(title:isSelected:action:)`.
- Colores: acento = `Color.accentColor` (asset con light #1976D2 / dark #B3D4FF). Estados: `Color.statusColor(booking.status)` con fondo `Metrics.statusBackgroundAlpha` (lo hace `StatusBadge`). Gradiente de slots: `LinearGradient(colors: Color.slotGradientColors, ...)`.
- Formatos (`Core/DesignSystem/BookifyFormat.swift`):
  - `BookifyFormat.dateTime(iso)` → "8 oct 2026, 10:00" (string crudo si el parseo ISO falla).
  - `BookifyFormat.dateRange(start:end:)` → "8 oct 2026, 10:00 - 11:00".
  - `BookifyFormat.queryDate(Date)` → "yyyy-MM-dd".
  - `BookifyFormat.price(1234.5)` → "MXN 1234.50"; `.minutes(30)` → "30 min"; `.people(4)` → "4 personas"; `.timeRange(opening:closing:)` → "09:00 - 17:00" (nil si falta alguno).

## 2. Casos de uso (llamada: `await caso(argumentos:)`, todos devuelven `AppResult<T>` salvo donde diga)

```swift
await login(email: String, password: String) -> AppResult<Void>
await register(name: String, email: String, password: String) -> AppResult<Void>
await forgotPassword(email: String) -> AppResult<String>          // mensaje del server
await resetPassword(code: String, newPassword: String, confirmPassword: String) -> AppResult<String>
logout()                                                          // void, solo local
currentUser() -> User?                                            // sin await
await getServices(page: Int, size: Int = 10) -> AppResult<PaginatedResponse<Service>>
await getServiceAvailability(serviceId: Int, date: String) -> AppResult<AvailabilityResponse>
await getServiceById(id: Int) -> AppResult<Service?>              // escanea page 0 size 100
await getServiceNames() -> [Int: String]                          // NUNCA falla ([] en error)
await getBookings(page: Int, size: Int = 10, status: BookingStatus? = nil) -> AppResult<PaginatedResponse<Booking>>
await createBooking(serviceId: Int, startAt: String, endAt: String) -> AppResult<Booking>
await cancelBooking(id: Int) -> AppResult<Void>
await createService(params: ServiceParams) -> AppResult<Service>
await updateService(id: Int, params: ServiceParams) -> AppResult<Service>
await deleteService(id: Int) -> AppResult<Void>
```

Fábricas en `DIContainer` (`container.makeLogin()`, `makeRegister()`, `makeForgotPassword()`, `makeResetPassword()`, `makeLogout()`, `makeGetCurrentUser()`, `makeGetServices()`, `makeGetServiceAvailability()`, `makeGetServiceById()`, `makeGetServiceNames()`, `makeGetBookings()`, `makeCreateBooking()`, `makeCancelBooking()`, `makeCreateService()`, `makeUpdateService()`, `makeDeleteService()`), además de `container.session` (SessionStore) y `container.preferences` (PreferencesStore).

Validaciones viven en los casos de uso (no en las vistas); los mensajes salen de `ValidationError.message`.
Fallbacks de mensaje de vista: login `"Error desconocido"`; register/recuperación/form `"Error del servidor"`; disponibilidad `"Error al cargar disponibilidad"`; servicios `"Error al cargar servicios"`; resto `"Error del servidor"`.

## 3. Protocolos de output (copiar LITERALMENTE; los coordinadores ya conforman a todos)

```swift
@MainActor
protocol LoginViewModelOutput: AnyObject {
    func loginSucceeded()
    func registerRequested()
    func passwordRecoveryRequested()
}

@MainActor
protocol RegisterViewModelOutput: AnyObject {
    func registerSucceeded()
    func closeRegister()
}

@MainActor
protocol PasswordRecoveryViewModelOutput: AnyObject {
    func closeRecovery()
}

@MainActor
protocol ServiceListOutput: AnyObject {
    func openService(_ service: Service)
}

@MainActor
protocol ServiceDetailOutput: AnyObject {
    func openAvailability(_ service: Service)
    func closeServiceDetail()
}

@MainActor
protocol AvailabilityOutput: AnyObject {
    func bookingCreated()
    func closeAvailability()
}

@MainActor
protocol BookingListOutput: AnyObject {
    func openBooking(id: Int)
}

@MainActor
protocol BookingDetailOutput: AnyObject {
    func closeBookingDetail()
}

@MainActor
protocol ProfileOutput: AnyObject {
    func logoutRequested()
    func themeChanged(_ mode: ThemeMode)
}

@MainActor
protocol AdminServiceListOutput: AnyObject {
    func createServiceRequested()
}

@MainActor
protocol ServiceFormOutput: AnyObject {
    func serviceSaved()
    func openMapPicker(latitudeText: String, longitudeText: String, onPick: @escaping (String, String) -> Void)
}

@MainActor
protocol AdminBookingsOutput: AnyObject {
    func openBooking(id: Int)
}

@MainActor
protocol MapPickerOutput: AnyObject {
    func pickConfirmed(latitude: String, longitude: String)
    func closeMapPicker()
}
```

Definir el protocolo en el MISMO archivo del ViewModel cuyo nombre lleva.

## 4. Fábricas de escena (definir exactamente; los coordinadores ya las llaman)

```swift
// Bookify/Features/Auth/AuthSceneFactory.swift
struct AuthSceneFactory {
    let container: DIContainer
    func makeLogin(coordinator: AuthCoordinator) -> LoginView
    func makeRegister(coordinator: AuthCoordinator) -> RegisterView
    func makePasswordRecovery(coordinator: AuthCoordinator) -> PasswordRecoveryView
}

// Bookify/Features/Client/ClientSceneFactory.swift
struct ClientSceneFactory {
    let container: DIContainer
    func makeServiceList(coordinator: ClientCoordinator) -> ServiceListView
    func makeServiceDetail(service: Service, coordinator: ClientCoordinator) -> ServiceDetailView
    func makeAvailability(service: Service, coordinator: ClientCoordinator) -> AvailabilityView
    func makeBookingList(coordinator: ClientCoordinator) -> BookingListView
    func makeBookingDetail(bookingId: Int, coordinator: ClientCoordinator) -> BookingDetailView
    func makeProfile(coordinator: ClientCoordinator) -> ProfileView
}

// Bookify/Features/Admin/AdminSceneFactory.swift
struct AdminSceneFactory {
    let container: DIContainer
    func makeServiceList(coordinator: AdminCoordinator) -> AdminServiceListView
    func makeServiceForm(mode: ServiceFormMode, coordinator: AdminCoordinator) -> ServiceFormView
    func makeBookings(coordinator: AdminCoordinator) -> AdminBookingsView
    func makeBookingDetail(bookingId: Int, coordinator: AdminCoordinator) -> BookingDetailView
    func makeMapPicker(coordinator: AdminCoordinator) -> MapPickerView
    func makeProfile(coordinator: AdminCoordinator) -> ProfileView
}
```

Inicializadores de vistas/VMs (respetar al pie de la letra):

```swift
LoginView(viewModel: LoginViewModel(login: container.makeLogin(), output: coordinator))
RegisterView(viewModel: RegisterViewModel(register: container.makeRegister(), output: coordinator))
PasswordRecoveryView(viewModel: PasswordRecoveryViewModel(forgotPassword: container.makeForgotPassword(), resetPassword: container.makeResetPassword(), output: coordinator))

ServiceListView(viewModel: ServiceListViewModel(getServices: container.makeGetServices(), output: coordinator), coordinator: coordinator)
ServiceDetailView(viewModel: ServiceDetailViewModel(service: service, output: coordinator))
AvailabilityView(viewModel: AvailabilityViewModel(service: service, getServiceAvailability: container.makeGetServiceAvailability(), output: coordinator),
                 createBookingViewModel: CreateBookingViewModel(service: service, createBooking: container.makeCreateBooking(), output: coordinator))
BookingListView(viewModel: BookingListViewModel(getBookings: container.makeGetBookings(), getServiceNames: container.makeGetServiceNames(), output: coordinator), coordinator: coordinator)
BookingDetailView(viewModel: BookingDetailViewModel(bookingId: bookingId, getBookings: container.makeGetBookings(), getServiceById: container.makeGetServiceById(), cancelBooking: container.makeCancelBooking(), output: coordinator))
ProfileView(viewModel: ProfileViewModel(getCurrentUser: container.makeGetCurrentUser(), preferences: container.preferences, output: coordinator))

AdminServiceListView(viewModel: AdminServiceListViewModel(getServices: container.makeGetServices(), deleteService: container.makeDeleteService(), output: coordinator), coordinator: coordinator)
ServiceFormView(viewModel: ServiceFormViewModel(mode: mode, getServiceById: container.makeGetServiceById(), createService: container.makeCreateService(), updateService: container.makeUpdateService(), output: coordinator))
AdminBookingsView(viewModel: AdminBookingsViewModel(getBookings: container.makeGetBookings(), getServiceNames: container.makeGetServiceNames(), output: coordinator), coordinator: coordinator)
MapPickerView(viewModel: MapPickerViewModel(latitude: coordinator.mapPickerInitialLatitude, longitude: coordinator.mapPickerInitialLongitude, output: coordinator))
```

`ProfileView` y `BookingDetailView` son compartidas (las escribe el módulo Client; Admin solo las instancia).

## 5. Reglas de UI comunes

- Estado vacío/error de listas: `ErrorStateView(message: error.message ?? "<fallback>", onRetry: ...)`; el error **solo** se muestra si la lista está vacía (en listas de servicios). Mientras `isLoading && items.isEmpty` → `LoadingView()`.
- Pull-to-refresh con `.refreshable { await viewModel.refresh() }` en TODAS las listas.
- Listas: `ScrollView` + `LazyVStack` o `List`; filas con `.onAppear { viewModel.loadMoreIfNeeded(index: index) }` solo donde haya paginación infinita.
- Títulos de detalle incluyen el nombre del servicio (`service.name`).
- Textos en español.

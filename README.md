# Bookify

App iOS para agendar citas de servicios (corte de pelo, etc.) con roles de cliente y administrador. Puerto de una app Android original, construida con SwiftUI y arquitectura Clean Architecture + coordinadores.

## Requisitos

- Xcode 26.5+
- iOS 17.0+
- Backend desplegado en Render (o local en DEV)

## Estructura

```
Bookify/
├── Core/
│   ├── Network/       APIClient, Endpoint, AppConfig
│   ├── Storage/       KeychainStore, SessionStore, PreferencesStore
│   ├── DI/            DIContainer
│   ├── Domain/
│   │   ├── Models/    User, Service, Booking, AuthResponse, PaginatedResponse
│   │   ├── Repositories/  AuthRepository, ServiceRepository, BookingRepository
│   │   ├── UseCases/  Auth/, Services/, Bookings/
│   │   └── Errors/    AppError, ValidationError, ErrorMapper
│   ├── Data/          Remote*Repository + DTOs
│   ├── Navigation/    AppCoordinator, Auth/Client/Admin coordinators
│   └── DesignSystem/  Colors, Theme, Components
└── Features/
    ├── Auth/          Login, Register, PasswordRecovery
    ├── Client/        ServiceList, ServiceDetail, Availability, CreateBooking, BookingList, BookingDetail, Profile
    └── Admin/         ServiceList, ServiceForm, MapPicker, Bookings, Profile
```

## Esquemas de compilación

| Esquema | Config | Flag | URL backend |
|---|---|---|---|
| `BookifyDev` | Debug | `DEV` | `http://192.168.101.115:8080` (LAN) |
| `BookifyProd` | Release | `PROD` | `https://bookify-backend-1qs6.onrender.com` |

La URL base se define en `Config/Dev.xcconfig` y `Config/Prod.xcconfig` (variable `BOOKIFY_BASE_URL`) y se inyecta vía `Info.plist` (`BookifyBaseURL`). Para apuntar DEV a otra IP, edita `Config/Dev.xcconfig`.

## Configuración

- `Config/Base.xcconfig`: `DEVELOPMENT_TEAM` compartido.
- `Config/Dev.xcconfig`: URL de desarrollo (HTTP en LAN; ATS deshabilitado solo en DEV).
- `Config/Prod.xcconfig`: URL de producción (HTTPS; ATS estricto).
- `Config/Info-Dev.plist`: `NSAllowsArbitraryLoads = true` (solo DEV, necesario para IP en crudo).
- `Config/Info-Prod.plist`: sin excepciones ATS (Producción exige HTTPS).

## Seguridad

- Tokens de acceso y refresh guardados en el **Keychain** (`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`), no en UserDefaults.
- Logout revoca la sesión en el servidor (`POST api/auth/logout`) y luego limpia el Keychain local.
- Refresco de token ante 401 con deduplicación de peticiones concurrentes.
- Política de contraseñas: mínimo 8 caracteres con al menos una letra y un número.

## Arquitectura

- **Clean Architecture**: Domain (models, use cases, repositories protocols) → Data (remote repositories, DTOs) → Presentation (views, view models).
- **Coordinator**: `AppCoordinator` maneja las fases (auth/client/admin); cada flujo tiene su propio coordinator con `NavigationStack`.
- **DI**: `DIContainer` con fábricas `makeXxx()` para use cases y repositorios.
- **Concurrency**: Swift concurrency (`async/await`), `@Observable`, aislamiento en `MainActor`.

## Tests

```bash
xcodebuild test -scheme BookifyDev -destination 'platform=iOS Simulator,name=iPhone 16'
```

Los tests unitarios cubren validación de auth, mapeo de errores, paginación y sesión (ver `BookifyTests/`).

## Notas

- Documento de paridad con la app Android original: [`PARITY.md`](PARITY.md).
- Contrato de funcionalidad: [`CONTRACT.md`](CONTRACT.md).

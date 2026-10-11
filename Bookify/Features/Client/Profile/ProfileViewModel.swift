import Foundation
import Observation

@MainActor
protocol ProfileOutput: AnyObject {
    func logoutRequested()
    func themeChanged(_ mode: ThemeMode)
}

@MainActor
@Observable
final class ProfileViewModel {
    struct UiState {
        var name = ""
        var email = ""
        var roleLabel = ""
        var themeMode: ThemeMode
    }

    var state: UiState
    private let preferences: PreferencesStore
    weak var output: ProfileOutput?

    init(getCurrentUser: GetCurrentUser, preferences: PreferencesStore, output: ProfileOutput) {
        self.preferences = preferences
        self.output = output
        var initialState = UiState(themeMode: preferences.themeMode)
        if let user = getCurrentUser() {
            initialState.name = user.name
            initialState.email = user.email
            initialState.roleLabel = user.role == .admin ? "Administrador" : "Cliente"
        }
        state = initialState
    }

    func changeTheme(_ mode: ThemeMode) {
        state.themeMode = mode
        preferences.themeMode = mode
        output?.themeChanged(mode)
    }

    func logout() {
        output?.logoutRequested()
    }
}

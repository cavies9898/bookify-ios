import Foundation

@MainActor
protocol PreferencesStore: AnyObject {
    var themeMode: ThemeMode { get set }
}

@MainActor
final class UserDefaultsPreferences: PreferencesStore {
    private let defaults: UserDefaults
    private static let themeKey = "theme_mode"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var themeMode: ThemeMode {
        get {
            guard let raw = defaults.string(forKey: Self.themeKey) else { return .system }
            return ThemeMode(rawValue: raw) ?? .system
        }
        set {
            defaults.set(newValue.rawValue, forKey: Self.themeKey)
        }
    }
}

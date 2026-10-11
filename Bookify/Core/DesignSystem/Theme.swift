import SwiftUI

enum ThemeMode: String, CaseIterable, Sendable {
    case system
    case light
    case dark

    var label: String {
        switch self {
        case .system: "Sistema"
        case .light: "Claro"
        case .dark: "Oscuro"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

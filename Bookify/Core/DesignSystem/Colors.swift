import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: 1.0
        )
    }

    static let statusConfirmed = Color(hex: 0x2E7D32)
    static let statusCancelled = Color(hex: 0xC62828)
    static let statusPending = Color(hex: 0xF9A825)

    static let slotGradientColors: [Color] = [
        Color(hex: 0x2196F3),
        Color(hex: 0x42A5F5),
        Color(hex: 0x64B5F6)
    ]

    static func statusColor(_ status: BookingStatus) -> Color {
        switch status {
        case .confirmed: .statusConfirmed
        case .cancelled: .statusCancelled
        case .pending: .statusPending
        }
    }
}

enum Metrics {
    static let statusBackgroundAlpha: Double = Double(0x26) / 255.0
    static let cornerRadius: CGFloat = 12
}

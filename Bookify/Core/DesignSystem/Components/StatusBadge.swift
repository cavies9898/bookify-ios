import SwiftUI
import UIKit

struct StatusBadge: View {
    let status: BookingStatus

    var body: some View {
        Text(status.label)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.statusColor(status).opacity(Metrics.statusBackgroundAlpha))
            .foregroundStyle(Color.statusColor(status))
            .clipShape(Capsule())
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

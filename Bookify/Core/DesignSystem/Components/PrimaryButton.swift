import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title).fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .background(Color.accentColor.opacity(interactive ? 1 : 0.5))
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
        .disabled(!interactive)
    }

    private var interactive: Bool {
        isEnabled && !isLoading
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .foregroundStyle(Color.accentColor)
        .overlay(
            RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                .stroke(Color.accentColor, lineWidth: 1)
        )
    }
}

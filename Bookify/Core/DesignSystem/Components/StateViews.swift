import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorStateView: View {
    let message: String
    var retryTitle: String = "Reintentar"
    var onRetry: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label("Error", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            if let onRetry {
                Button(retryTitle, action: onRetry)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

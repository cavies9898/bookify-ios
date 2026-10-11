import SwiftUI
import Observation
import UIKit

struct CreateBookingView: View {
    @Bindable var viewModel: CreateBookingViewModel

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("Confirmando reserva…")
                .font(.subheadline)
                .fontWeight(.semibold)
            Spacer(minLength: 8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
        .opacity(viewModel.state.isSubmitting ? 1 : 0.5)
    }
}

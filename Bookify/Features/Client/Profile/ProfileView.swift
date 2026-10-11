import SwiftUI
import Observation
import UIKit

struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel

    private var state: ProfileViewModel.UiState { viewModel.state }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.accentColor)
                    .padding(.top, 16)
                VStack(spacing: 4) {
                    Text(state.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(state.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if !state.roleLabel.isEmpty {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("Rol")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 8)
                        Text(state.roleLabel)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tema")
                        .font(.headline)
                    Picker("Tema", selection: $viewModel.state.themeMode) {
                        ForEach(ThemeMode.allCases, id: \.self) { mode in
                            Text(mode.label)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.state.themeMode) { mode in
                        viewModel.changeTheme(mode)
                    }
                }
                Button("Cerrar sesión", role: .destructive) {
                    viewModel.logout()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
                .foregroundStyle(Color.statusCancelled)
            }
            .padding()
        }
    }
}

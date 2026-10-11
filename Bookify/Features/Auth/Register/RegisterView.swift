import SwiftUI
import Observation

struct RegisterView: View {
    @Bindable var viewModel: RegisterViewModel

    private var state: RegisterViewModel.UiState { viewModel.state }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AppTextField(
                    title: "Nombre completo",
                    text: $viewModel.state.name,
                    error: state.nameError
                )
                AppTextField(
                    title: "Correo electrónico",
                    text: $viewModel.state.email,
                    error: state.emailError,
                    keyboard: .emailAddress
                )
                AppTextField(
                    title: "Contraseña",
                    text: $viewModel.state.password,
                    isSecure: true,
                    error: state.passwordError
                )
                if let errorMessage = state.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                PrimaryButton(title: "Crear cuenta", isLoading: state.isLoading) {
                    Task { await viewModel.submit() }
                }
                Button("¿Ya tienes cuenta? Inicia sesión") {
                    viewModel.output?.closeRegister()
                }
                .foregroundStyle(Color.accentColor)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Crear cuenta")
        .navigationBarTitleDisplayMode(.inline)
    }
}

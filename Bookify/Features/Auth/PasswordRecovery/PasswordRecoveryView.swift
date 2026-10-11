import SwiftUI
import Observation

struct PasswordRecoveryView: View {
    @Bindable var viewModel: PasswordRecoveryViewModel

    private var state: PasswordRecoveryViewModel.UiState { viewModel.state }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                switch state.step {
                case 1:
                    stepOne
                case 2:
                    stepTwo
                default:
                    stepThree
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Recuperar contraseña")
        .navigationBarTitleDisplayMode(.inline)
    }

    //MARK: - Ingresar email
    private var stepOne: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Ingresa tu correo")
                    .font(.title2.bold())

                Text("Te enviaremos un código para restablecer tu contraseña.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .padding(.bottom, 8)

            AppTextField(
                title: "Correo electrónico",
                text: $viewModel.state.email,
                placeholder: "tu@gmail.com",
                error: state.emailError,
                keyboard: .emailAddress
            )

            if let errorMessage = state.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            PrimaryButton(
                title: "Enviar código",
                isLoading: state.isLoading
            ) {
                Task {
                    await viewModel.requestCode()
                }
            }

            SecondaryButton(title: "Cancelar") {
                viewModel.backToStart()
            }
        }
    }

    private var stepTwo: some View {
        VStack(spacing: 16) {
            Text(state.email)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let serverMessage = state.serverMessage {
                Text(serverMessage)
                    .font(.footnote)
                    .foregroundStyle(Color.accentColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            AppTextField(
                title: "Código de 6 dígitos",
                text: $viewModel.state.code,
                error: state.codeError,
                keyboard: .numberPad
            )
            .onChange(of: viewModel.state.code) { _, newValue in
                viewModel.state.code = String(newValue.prefix(6))
            }
            AppTextField(
                title: "Nueva contraseña",
                text: $viewModel.state.newPassword,
                placeholder: "Mínimo 8 caracteres",
                isSecure: true,
                error: state.newPasswordError
            )
            AppTextField(
                title: "Confirmar contraseña",
                text: $viewModel.state.confirmPassword,
                isSecure: true,
                error: state.confirmPasswordError
            )
            if let errorMessage = state.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            PrimaryButton(title: "Restablecer contraseña", isLoading: state.isLoading) {
                Task { await viewModel.resetPassword() }
            }
        }
    }

    private var stepThree: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
                .padding(.top, 48)
            Text("Contraseña restablecida")
                .font(.title2)
                .fontWeight(.bold)
            Text("Tu contraseña se restableció correctamente")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            PrimaryButton(title: "Volver al inicio de sesión") {
                viewModel.output?.closeRecovery()
            }
        }
    }
}

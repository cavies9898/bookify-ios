import SwiftUI
import Observation

struct LoginView: View {
    @Bindable var viewModel: LoginViewModel

    private var state: LoginViewModel.UiState {
        viewModel.state
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Header
                header
                    .padding(.top, 40)

                // MARK: - Form
                VStack(spacing: 18) {
                    AppTextField(
                        title: "Correo electrónico",
                        text: $viewModel.state.email,
                        placeholder: "tu@email.com",
                        error: state.emailError,
                        keyboard: .emailAddress,
                        textContentType: .emailAddress
                    )
                    .onChange(of: viewModel.state.email) {
                        viewModel.state.emailError = nil
                    }

                    AppTextField(
                        title: "Contraseña",
                        text: $viewModel.state.password,
                        placeholder: "Ingresa tu contraseña",
                        isSecure: true,
                        error: state.passwordError,
                        textContentType: .password
                    )
                    .onChange(of: viewModel.state.password) {
                        viewModel.state.passwordError = nil
                    }

                    // MARK: - General error
                    if let errorMessage = state.errorMessage {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.caption)

                            Text(errorMessage)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundStyle(.red)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.horizontal, 4)
                        .transition(
                            .opacity.combined(
                                with: .move(edge: .top)
                            )
                        )
                    }

                    // MARK: - Login button
                    PrimaryButton(
                        title: "Ingresar",
                        isLoading: state.isLoading
                    ) {
                        Task {
                            await viewModel.submit()
                        }
                    }
                    .padding(.top, 6)
                }
                .padding(.top, 36)

                // MARK: - Password recovery
                Button {
                    viewModel.output?.passwordRecoveryRequested()
                } label: {
                    Text("¿Olvidaste tu contraseña?")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(Color.accentColor)
                .padding(.top, 20)

                // MARK: - Divider
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 1)

                    Text("o")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 1)
                }
                .padding(.vertical, 24)

                // MARK: - Register
                Button {
                    viewModel.output?.registerRequested()
                } label: {
                    HStack(spacing: 4) {
                        Text("¿No tienes cuenta?")
                            .foregroundStyle(.secondary)

                        Text("Regístrate")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentColor)
                    }
                    .font(.subheadline)
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: 500)
            .frame(
                maxWidth: .infinity,
                minHeight: 500
            )
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.accentColor)
                    .frame(width: 72, height: 72)

                Image(systemName: "book.closed.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 6) {
                Text("Bienvenido a Bookify")
                    .font(.title2.weight(.bold))

                Text("Inicia sesión para continuar")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

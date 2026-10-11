import SwiftUI
import Observation
import MapKit

struct ServiceFormView: View {
    @Bindable var viewModel: ServiceFormViewModel

    private var state: ServiceFormViewModel.UiState {
        viewModel.state
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Información básica

                FormSection(
                    title: "Información del servicio",
                    subtitle: "Define los datos principales de tu servicio"
                ) {
                    VStack(spacing: 18) {
                        AppTextField(
                            title: "Nombre",
                            text: $viewModel.state.name,
                            placeholder: "Ej. Corte de cabello"
                        )

                        AppTextField(
                            title: "Descripción",
                            text: $viewModel.state.description,
                            placeholder: "Describe tu servicio",
                        )
                    }
                }

                // MARK: - Configuración

                FormSection(
                    title: "Configuración",
                    subtitle: "Define duración, capacidad y precio"
                ) {
                    VStack(spacing: 14) {
                        FormStepperRow(
                            title: "Duración",
                            subtitle: "Tiempo aproximado del servicio",
                            value: "\(state.durationMinutes) min"
                        ) {
                            Stepper(
                                "",
                                value: $viewModel.state.durationMinutes,
                                in: 15...480,
                                step: 15
                            )
                            .labelsHidden()
                        }

                        Divider()

                        FormStepperRow(
                            title: "Capacidad",
                            subtitle: "Personas que puedes atender",
                            value: "\(state.capacity)"
                        ) {
                            Stepper(
                                "",
                                value: $viewModel.state.capacity,
                                in: 1...100,
                                step: 1
                            )
                            .labelsHidden()
                        }

                        Divider()

                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Precio")
                                    .font(.subheadline.weight(.medium))

                                Text("Precio por servicio")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            HStack(spacing: 8) {
                                TextField(
                                    "0.00",
                                    text: $viewModel.state.priceText
                                )
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 90)

                                Text("MXN")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // MARK: - Horario

                FormSection(
                    title: "Horario",
                    subtitle: "Indica cuándo estará disponible el servicio"
                ) {
                    HStack(spacing: 12) {
                        AppTextField(
                            title: "Apertura",
                            text: $viewModel.state.openingTime,
                            placeholder: "09:00"
                        )

                        AppTextField(
                            title: "Cierre",
                            text: $viewModel.state.closingTime,
                            placeholder: "18:00"
                        )
                    }
                }

                // MARK: - Ubicación

                FormSection(
                    title: "Ubicación",
                    subtitle: "Indica dónde se ofrece el servicio"
                ) {
                    VStack(spacing: 18) {
                        AppTextField(
                            title: "Dirección",
                            text: $viewModel.state.location,
                            placeholder: "Ej. Av. Reforma 123"
                        )

                        HStack(spacing: 12) {
                            AppTextField(
                                title: "Latitud",
                                text: $viewModel.state.latitudeText,
                                placeholder: "19.4326",
                                keyboard: .decimalPad
                            )

                            AppTextField(
                                title: "Longitud",
                                text: $viewModel.state.longitudeText,
                                placeholder: "-99.1332",
                                keyboard: .decimalPad
                            )
                        }

                        SecondaryButton(
                            title: "Seleccionar en mapa"
                        ) {
                            viewModel.openMapPicker()
                        }

                        if let coordinate = viewModel.selectedCoordinate {
                            Map(position: .constant(.region(
                                MKCoordinateRegion(
                                    center: coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                            )), interactionModes: []) {
                                Annotation("Ubicación", coordinate: coordinate) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                        .foregroundStyle(.red)
                                }
                            }
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
                            .allowsHitTesting(false)
                        }
                    }
                }

                // MARK: - Error

                if let errorMessage = state.errorMessage {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")

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
                }

                // MARK: - Save

                PrimaryButton(
                    title: state.isEditing
                        ? "Guardar cambios"
                        : "Crear servicio",
                    isLoading: state.isLoading,
                    isEnabled: viewModel.canSave
                ) {
                    Task {
                        await viewModel.save()
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(
            state.isEditing
                ? "Editar servicio"
                : "Nuevo servicio"
        )
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadInitial()
        }
    }
}

// MARK: - Form Section

private struct FormSection<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
        }
    }
}

// MARK: - Stepper Row

private struct FormStepperRow<Control: View>: View {
    let title: String
    let subtitle: String
    let value: String
    @ViewBuilder let control: Control

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.medium))

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(value)
                    .font(.subheadline.weight(.semibold))

                control
            }
        }
    }
}

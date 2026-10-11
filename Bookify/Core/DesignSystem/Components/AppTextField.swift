import SwiftUI
import UIKit

struct AppTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var error: String?
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var axis: Axis = .horizontal

    @FocusState private var isFocused: Bool
    @State private var isTextVisible = false

    private var hasError: Bool {
        guard let error else { return false }
        return !error.isEmpty
    }

    private var borderColor: Color {
        if hasError {
            return .red
        }

        if isFocused {
            return .accentColor
        }

        return Color(.separator)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(hasError ? .red : .secondary)

            HStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    // Placeholder
                    if text.isEmpty && !isFocused {
                        Text(placeholder)
                            .foregroundStyle(.secondary)
                            .allowsHitTesting(false)
                    }

                    // Text field
                    Group {
                        if isSecure && !isTextVisible {
                            SecureField("", text: $text)
                        } else {
                            TextField("", text: $text, axis: axis)
                        }
                    }
                    .textFieldStyle(.plain)
                    .keyboardType(keyboard)
                    .textContentType(textContentType)
                    .textInputAutocapitalization(
                        keyboard == .emailAddress
                            ? .never
                            : .sentences
                    )
                    .autocorrectionDisabled(
                        keyboard == .emailAddress
                    )
                    .focused($isFocused)
                }

                // Password visibility button
                if isSecure {
                    Button {
                        isTextVisible.toggle()
                    } label: {
                        Image(
                            systemName: isTextVisible
                                ? "eye.slash"
                                : "eye"
                        )
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        isTextVisible
                            ? "Ocultar contraseña"
                            : "Mostrar contraseña"
                    )
                }
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        borderColor,
                        lineWidth: isFocused || hasError ? 1.5 : 1
                    )
            }
            .animation(
                .easeInOut(duration: 0.15),
                value: isFocused
            )
            .animation(
                .easeInOut(duration: 0.15),
                value: hasError
            )

            if let error, !error.isEmpty {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

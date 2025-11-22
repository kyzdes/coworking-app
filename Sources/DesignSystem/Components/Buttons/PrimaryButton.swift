import SwiftUI

/// Primary action button with customizable style
public struct PrimaryButton: View {
    private let title: String
    private let icon: String?
    private let action: () -> Void
    private let style: ButtonStyle
    private let size: Size
    private let isLoading: Bool
    private let isDisabled: Bool

    public enum ButtonStyle {
        case filled
        case outlined
        case text

        var foregroundColor: Color {
            switch self {
            case .filled: return .white
            case .outlined: return .primaryAccent
            case .text: return .primaryAccent
            }
        }

        var backgroundColor: Color {
            switch self {
            case .filled: return .primaryAccent
            case .outlined: return .clear
            case .text: return .clear
            }
        }

        var borderColor: Color {
            switch self {
            case .filled: return .clear
            case .outlined: return .primaryAccent
            case .text: return .clear
            }
        }
    }

    public enum Size {
        case small
        case medium
        case large

        var height: CGFloat {
            switch self {
            case .small: return ButtonSize.sm
            case .medium: return ButtonSize.md
            case .large: return ButtonSize.lg
            }
        }

        var font: Font {
            switch self {
            case .small: return .bodyCallout
            case .medium: return .bodyHeadline
            case .large: return .bodyHeadline
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return Spacing.md
            case .medium: return Spacing.lg
            case .large: return Spacing.xl
            }
        }
    }

    public init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .filled,
        size: Size = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(style.foregroundColor)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(size.font)
                    }

                    Text(title)
                        .font(size.font)
                        .fontWeight(.semibold)
                }
            }
            .foregroundStyle(isDisabled ? Color.labelTertiary : style.foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(isDisabled ? Color.backgroundTertiary : style.backgroundColor)
            .cornerRadius(CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(
                        isDisabled ? Color.labelQuaternary : style.borderColor,
                        lineWidth: style == .outlined ? 2 : 0
                    )
            )
        }
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        PrimaryButton("Start Session", icon: "play.fill") {
            print("Tapped")
        }

        PrimaryButton("Outlined", style: .outlined) {
            print("Tapped")
        }

        PrimaryButton("Text Button", style: .text) {
            print("Tapped")
        }

        PrimaryButton("Loading", isLoading: true) {
            print("Tapped")
        }

        PrimaryButton("Disabled", isDisabled: true) {
            print("Tapped")
        }

        PrimaryButton("Small", size: .small) {
            print("Tapped")
        }

        PrimaryButton("Large", size: .large) {
            print("Tapped")
        }
    }
    .padding()
}

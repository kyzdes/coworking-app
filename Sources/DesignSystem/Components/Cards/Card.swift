import SwiftUI

/// Generic card component with customizable style
public struct Card<Content: View>: View {
    private let content: Content
    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let shadowRadius: CGFloat

    public init(
        padding: CGFloat = Spacing.lg,
        cornerRadius: CGFloat = CornerRadius.lg,
        shadowRadius: CGFloat = 4,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }

    public var body: some View {
        content
            .padding(padding)
            .background(Color.backgroundSecondary)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: shadowRadius, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        Card {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Card Title")
                    .font(.bodyHeadline)
                    .foregroundStyle(Color.labelPrimary)

                Text("Card content goes here with some description text.")
                    .font(.bodyRegular)
                    .foregroundStyle(Color.labelSecondary)
            }
        }

        Card(padding: Spacing.md) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.success)

                Text("Success message")
                    .font(.bodyCallout)
            }
        }
    }
    .padding()
    .background(Color.backgroundPrimary)
}

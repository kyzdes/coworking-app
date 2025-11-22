import SwiftUI

/// App typography supporting Dynamic Type
public extension Font {
    // MARK: - Display Fonts

    /// Large title - Extra large text
    static let displayLarge = Font.system(.largeTitle, design: .rounded, weight: .bold)

    /// Title 1 - Large title
    static let displayTitle = Font.system(.title, design: .rounded, weight: .bold)

    /// Title 2 - Medium title
    static let displayTitle2 = Font.system(.title2, design: .rounded, weight: .semibold)

    /// Title 3 - Small title
    static let displayTitle3 = Font.system(.title3, design: .rounded, weight: .semibold)

    // MARK: - Body Fonts

    /// Headline - Emphasized body text
    static let bodyHeadline = Font.system(.headline, design: .default, weight: .semibold)

    /// Body - Regular body text
    static let bodyRegular = Font.system(.body, design: .default, weight: .regular)

    /// Callout - Slightly smaller than body
    static let bodyCallout = Font.system(.callout, design: .default, weight: .regular)

    /// Subheadline - Secondary body text
    static let bodySubheadline = Font.system(.subheadline, design: .default, weight: .regular)

    /// Footnote - Small body text
    static let bodyFootnote = Font.system(.footnote, design: .default, weight: .regular)

    // MARK: - Caption Fonts

    /// Caption 1 - Primary caption text
    static let captionPrimary = Font.system(.caption, design: .default, weight: .regular)

    /// Caption 2 - Secondary caption text
    static let captionSecondary = Font.system(.caption2, design: .default, weight: .regular)

    // MARK: - Special Fonts

    /// Timer display - Large monospaced digits
    static let timerDisplay = Font.system(size: 72, weight: .medium, design: .rounded)
        .monospacedDigit()

    /// Timer minutes - Medium monospaced digits
    static let timerMedium = Font.system(size: 48, weight: .medium, design: .rounded)
        .monospacedDigit()

    /// Timer small - Small monospaced digits
    static let timerSmall = Font.system(size: 24, weight: .medium, design: .rounded)
        .monospacedDigit()

    /// Code - Monospaced font for code or technical text
    static let code = Font.system(.body, design: .monospaced, weight: .regular)
}

// MARK: - Text Styles

public struct TextStyle {
    public static func title(_ text: String) -> some View {
        Text(text)
            .font(.displayTitle)
            .foregroundStyle(Color.labelPrimary)
    }

    public static func headline(_ text: String) -> some View {
        Text(text)
            .font(.bodyHeadline)
            .foregroundStyle(Color.labelPrimary)
    }

    public static func body(_ text: String) -> some View {
        Text(text)
            .font(.bodyRegular)
            .foregroundStyle(Color.labelPrimary)
    }

    public static func caption(_ text: String) -> some View {
        Text(text)
            .font(.captionPrimary)
            .foregroundStyle(Color.labelSecondary)
    }
}

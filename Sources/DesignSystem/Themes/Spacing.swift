import SwiftUI

/// Consistent spacing values across the app
public enum Spacing {
    /// 4pt
    public static let xs: CGFloat = 4

    /// 8pt
    public static let sm: CGFloat = 8

    /// 12pt
    public static let md: CGFloat = 12

    /// 16pt
    public static let lg: CGFloat = 16

    /// 20pt
    public static let xl: CGFloat = 20

    /// 24pt
    public static let xxl: CGFloat = 24

    /// 32pt
    public static let xxxl: CGFloat = 32

    /// 48pt
    public static let huge: CGFloat = 48
}

// MARK: - Corner Radius

public enum CornerRadius {
    /// 4pt
    public static let sm: CGFloat = 4

    /// 8pt
    public static let md: CGFloat = 8

    /// 12pt
    public static let lg: CGFloat = 12

    /// 16pt
    public static let xl: CGFloat = 16

    /// 24pt
    public static let xxl: CGFloat = 24

    /// Circle (50%)
    public static let circle: CGFloat = 999
}

// MARK: - Icon Sizes

public enum IconSize {
    /// 16pt
    public static let sm: CGFloat = 16

    /// 24pt
    public static let md: CGFloat = 24

    /// 32pt
    public static let lg: CGFloat = 32

    /// 48pt
    public static let xl: CGFloat = 48

    /// 64pt
    public static let xxl: CGFloat = 64
}

// MARK: - Avatar Sizes

public enum AvatarSize {
    /// 32pt
    public static let sm: CGFloat = 32

    /// 48pt
    public static let md: CGFloat = 48

    /// 64pt
    public static let lg: CGFloat = 64

    /// 96pt
    public static let xl: CGFloat = 96

    /// 128pt
    public static let xxl: CGFloat = 128
}

// MARK: - Button Sizes

public enum ButtonSize {
    /// Small button height: 36pt
    public static let sm: CGFloat = 36

    /// Medium button height: 44pt (iOS minimum touch target)
    public static let md: CGFloat = 44

    /// Large button height: 52pt
    public static let lg: CGFloat = 52

    /// Extra large button height: 60pt
    public static let xl: CGFloat = 60
}

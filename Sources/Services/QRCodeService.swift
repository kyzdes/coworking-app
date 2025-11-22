import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import AVFoundation
import Dependencies

/// Service for QR code generation and scanning
public actor QRCodeService {
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    public init() {}

    // MARK: - QR Code Generation

    /// Generate QR code image from user ID
    public func generateQRCode(for userId: UUID) -> UIImage? {
        // Create invite URL
        let inviteURL = "virtualoffice://invite/\(userId.uuidString)"
        return generateQRCode(from: inviteURL)
    }

    /// Generate QR code from string
    public func generateQRCode(from string: String) -> UIImage? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }

        filter.message = data
        filter.correctionLevel = "M" // Medium error correction

        guard let outputImage = filter.outputImage else {
            return nil
        }

        // Scale up the QR code
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)

        // Convert to UIImage
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    // MARK: - QR Code Scanning

    /// Check if device can scan QR codes
    public func canScanQRCodes() -> Bool {
        AVCaptureDevice.default(for: .video) != nil
    }

    /// Parse invite URL from scanned QR code
    public func parseInviteURL(_ urlString: String) -> UUID? {
        guard let url = URL(string: urlString),
              url.scheme == "virtualoffice",
              url.host == "invite",
              let userIdString = url.pathComponents.last,
              let userId = UUID(uuidString: userIdString) else {
            return nil
        }

        return userId
    }
}

// MARK: - Dependency

extension QRCodeService: DependencyKey {
    public static let liveValue = QRCodeService()
    public static let testValue = QRCodeService()
}

extension DependencyValues {
    public var qrCodeService: QRCodeService {
        get { self[QRCodeService.self] }
        set { self[QRCodeService.self] = newValue }
    }
}

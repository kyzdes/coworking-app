import SwiftUI
import AVFoundation

/// QR Code display view for sharing user ID
public struct QRCodeShareView: View {
    let qrCodeImage: UIImage?
    let username: String

    public init(qrCodeImage: UIImage?, username: String) {
        self.qrCodeImage = qrCodeImage
        self.username = username
    }

    public var body: some View {
        VStack(spacing: Spacing.xl) {
            Text("Share Your QR Code")
                .font(.displayTitle3)
                .foregroundStyle(Color.labelPrimary)

            Text("Let friends scan this code to add you")
                .font(.bodyRegular)
                .foregroundStyle(Color.labelSecondary)
                .multilineTextAlignment(.center)

            if let qrCodeImage = qrCodeImage {
                Image(uiImage: qrCodeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding(Spacing.xl)
                    .background(Color.white)
                    .cornerRadius(CornerRadius.xl)
                    .shadow(color: .black.opacity(0.1), radius: 10)
            } else {
                RoundedRectangle(cornerRadius: CornerRadius.xl)
                    .fill(Color.backgroundTertiary)
                    .frame(width: 250, height: 250)
                    .overlay {
                        VStack {
                            Image(systemName: "qrcode")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.labelTertiary)

                            Text("QR Code Unavailable")
                                .font(.caption)
                                .foregroundStyle(Color.labelTertiary)
                        }
                    }
            }

            Text("@\(username)")
                .font(.bodyHeadline)
                .foregroundStyle(Color.labelPrimary)

            PrimaryButton("Share", icon: "square.and.arrow.up") {
                shareQRCode()
            }
            .padding(.horizontal, Spacing.xxxl)
        }
        .padding(Spacing.xl)
    }

    private func shareQRCode() {
        guard let qrCodeImage = qrCodeImage else { return }

        let activityVC = UIActivityViewController(
            activityItems: [qrCodeImage],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - QR Code Scanner View

public struct QRCodeScannerView: View {
    @Binding var isPresented: Bool
    let onCodeScanned: (String) -> Void

    @State private var cameraPermission: CameraPermission = .notDetermined

    public init(
        isPresented: Binding<Bool>,
        onCodeScanned: @escaping (String) -> Void
    ) {
        self._isPresented = isPresented
        self.onCodeScanned = onCodeScanned
    }

    public var body: some View {
        ZStack {
            if cameraPermission == .authorized {
                QRScannerRepresentable { code in
                    onCodeScanned(code)
                    isPresented = false
                }
                .ignoresSafeArea()
            } else {
                permissionView
            }

            VStack {
                HStack {
                    Spacer()

                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }

                Spacer()

                if cameraPermission == .authorized {
                    Text("Align QR code within frame")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(CornerRadius.md)
                        .padding(.bottom, Spacing.xxxl)
                }
            }
        }
        .onAppear {
            checkCameraPermission()
        }
    }

    private var permissionView: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "camera.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.labelTertiary)

            Text(cameraPermission.message)
                .font(.bodyRegular)
                .foregroundStyle(Color.labelPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxxl)

            if cameraPermission == .notDetermined {
                PrimaryButton("Allow Camera Access") {
                    requestCameraPermission()
                }
                .padding(.horizontal, Spacing.xxxl)
            } else if cameraPermission == .denied {
                PrimaryButton("Open Settings") {
                    openSettings()
                }
                .padding(.horizontal, Spacing.xxxl)
            }
        }
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermission = .authorized
        case .denied, .restricted:
            cameraPermission = .denied
        case .notDetermined:
            cameraPermission = .notDetermined
        @unknown default:
            cameraPermission = .notDetermined
        }
    }

    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                cameraPermission = granted ? .authorized : .denied
            }
        }
    }

    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

// MARK: - Camera Permission

private enum CameraPermission {
    case notDetermined
    case authorized
    case denied

    var message: String {
        switch self {
        case .notDetermined:
            return "Camera access is needed to scan QR codes"
        case .authorized:
            return ""
        case .denied:
            return "Camera access was denied. Please enable it in Settings to scan QR codes."
        }
    }
}

// MARK: - QR Scanner UIViewControllerRepresentable

private struct QRScannerRepresentable: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.onCodeScanned = onCodeScanned
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

// MARK: - QR Scanner View Controller

private class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeScanned: ((String) -> Void)?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !(captureSession?.isRunning ?? false) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession?.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning ?? false {
            captureSession?.stopRunning()
        }
    }

    private func setupCamera() {
        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        self.captureSession = captureSession
        self.previewLayer = previewLayer

        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession?.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            onCodeScanned?(stringValue)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

// MARK: - Preview

#Preview("QR Share") {
    QRCodeShareView(
        qrCodeImage: nil,
        username: "john_doe"
    )
}

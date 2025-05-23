import StreamVideo
import StreamVideoSwiftUI
import SwiftUI
import SwiftUICore
import AVFoundation
import UIKit

// Include PermissionChecker directly in this file
enum PermissionStatus {
    case granted
    case denied
    case notDetermined

    var isGranted: Bool {
        self == .granted
    }

    var isAuthorized: Bool {
        self == .granted
    }
}

class PermissionChecker: ObservableObject {
    @Published var cameraPermissionStatus: PermissionStatus = .notDetermined
    @Published var microphonePermissionStatus: PermissionStatus = .notDetermined

    static let shared = PermissionChecker()

    private init() {
        checkCameraPermission()
        checkMicrophonePermission()
    }

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionStatus = .granted
        case .denied, .restricted:
            cameraPermissionStatus = .denied
        case .notDetermined:
            cameraPermissionStatus = .notDetermined
            requestCameraPermission()
        @unknown default:
            cameraPermissionStatus = .notDetermined
        }
    }

    func checkMicrophonePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            microphonePermissionStatus = .granted
        case .denied, .restricted:
            microphonePermissionStatus = .denied
        case .notDetermined:
            microphonePermissionStatus = .notDetermined
            requestMicrophonePermission()
        @unknown default:
            microphonePermissionStatus = .notDetermined
        }
    }

    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.cameraPermissionStatus = granted ? .granted : .denied
            }
        }
    }

    func requestMicrophonePermission() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            DispatchQueue.main.async {
                self?.microphonePermissionStatus = granted ? .granted : .denied
            }
        }
    }

    // New method to handle permission prompts when call opens
    func requestPermissionsIfPossible() {
        // For camera
        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            requestCameraPermission()
        }

        // For microphone
        if AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined {
            requestMicrophonePermission()
        }
    }

    // Alert user about denied permissions
    func showPermissionAlert(in viewController: UIViewController) {
        // Only show if at least one permission is denied
        guard cameraPermissionStatus == .denied || microphonePermissionStatus == .denied else {
            return
        }

        var message = "To use this app's full features:"

        if cameraPermissionStatus == .denied {
            message += "\n• Camera access is needed for video calls"
        }

        if microphonePermissionStatus == .denied {
            message += "\n• Microphone access is needed for audio"
        }

        message += "\n\nPlease update your permissions in Settings."

        let alert = UIAlertController(
            title: "Permission Required",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            self.openAppSettings()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        viewController.present(alert, animated: true)
    }

    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

public struct CustomCallControlsView: View {

    @Injected(\.streamVideo) var streamVideo
    @Injected(\.colors) var colors
    @ObservedObject private var permissionChecker = PermissionChecker.shared

    @ObservedObject var viewModel: CallViewModel
    @ObservedObject var uiStateViewModel: CallUIStateViewModel
    var preferredExtension: String
    var onCallEndedHandler: (() -> Void)?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    init(
        viewModel: CallViewModel,
        preferredExtension: String,
        uiStateViewModel: CallUIStateViewModel,
        onCallEnded: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.preferredExtension = preferredExtension
        self.uiStateViewModel = uiStateViewModel
        self.onCallEndedHandler = onCallEnded
    }

    public var body: some View {
        HStack {
            Spacer()

            Button {
                Task {
                    viewModel.hangUp()
                    viewModel.call?.leave()
                    onCallEndedHandler!()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 50, height: 50)
                    Image(systemName: "phone.down.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
            }

            // Always show video button regardless of capabilities to facilitate permission handling
            CustomVideoIconView(
                viewModel: viewModel,
                iconBackgroundColor: .white,
                iconForegroundColor: .black
            )

            // Always show microphone button regardless of capabilities to facilitate permission handling
            CustomMicrophoneIconView(
                viewModel: viewModel,
                iconBackgroundColor: .white,
                iconForegroundColor: .black
            )

            if #available(iOS 14.0, *) {
                CustomBroadcastIconView(
                    viewModel: viewModel,
                    preferredExtension: preferredExtension
                )
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, horizontalSizeClass == .regular ? 8 : 0)
        .frame(maxWidth: .infinity)
        .onAppear {
            permissionChecker.checkCameraPermission()
            permissionChecker.checkMicrophonePermission()
        }
    }

    private var call: Call? {
        switch viewModel.callingState {
        case .incoming, .outgoing:
            return streamVideo.state.ringingCall
        default:
            return viewModel.call
        }
    }
}

@available(iOS 14.0, *)
public struct CustomBroadcastIconView: View {

    @Injected(\.images) var images
    @Injected(\.colors) var colors

    @ObservedObject var viewModel: CallViewModel
    @StateObject var broadcastObserver = BroadcastObserver()
    let size: CGFloat
    let iconStyle = CallIconStyle.transparent
    let preferredExtension: String
    let iconSize: CGFloat = 44
    let offset: CGPoint

    public init(
        viewModel: CallViewModel,
        preferredExtension: String,
        size: CGFloat = 44
    ) {
        self.viewModel = viewModel
        self.preferredExtension = preferredExtension
        self.size = size
        offset = {
            if #available(iOS 16.0, *) {
                return .init(x: -5, y: -4)
            } else {
                return .zero
            }
        }()
    }

    public var body: some View {
        ZStack(alignment: .center) {
            Circle().fill(
                Color.white
            )
            BroadcastPickerView(
                preferredExtension: preferredExtension,
                size: iconSize
            )
            .frame(width: iconSize, height: iconSize)
            .offset(x: offset.x, y: offset.y)
            .foregroundColor(iconStyle.foregroundColor)
        }
        .frame(width: size, height: size)
        .modifier(ShadowModifier())
        .onChange(
            of: broadcastObserver.broadcastState,
            perform: { newValue in
                if newValue == .started {
                    viewModel.startScreensharing(type: .broadcast)
                } else if newValue == .finished {
                    viewModel.stopScreensharing()
                    broadcastObserver.broadcastState = .notStarted
                }
            }
        )
        .disabled(isDisabled)
        .onAppear {
            broadcastObserver.observe()
        }
    }

    private var isDisabled: Bool {
        guard viewModel.call?.state.screenSharingSession != nil else {
            return false
        }
        return viewModel.call?.state.isCurrentUserScreensharing == false
    }
}

struct ShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 12)
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

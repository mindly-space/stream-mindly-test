import StreamVideo
import StreamVideoSwiftUI
import SwiftUI
import SwiftUICore
import AVFoundation

/// Custom implementation of VideoIconView with customizable colors
public struct CustomVideoIconView: View {
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    @ObservedObject private var permissionChecker = PermissionChecker.shared

    @ObservedObject var viewModel: CallViewModel
    let iconBackgroundColor: Color
    let iconForegroundColor: Color
    let size: CGFloat

    public init(
        viewModel: CallViewModel,
        iconBackgroundColor: Color = .white,
        iconForegroundColor: Color = .black,
        size: CGFloat = 44
    ) {
        self.viewModel = viewModel
        self.iconBackgroundColor = iconBackgroundColor
        self.iconForegroundColor = iconForegroundColor
        self.size = size
    }

    public var body: some View {
        ZStack {
            CallControlIcon(
                icon: viewModel.callSettings.videoOn
                    ? images.videoTurnOn
                    : images.videoTurnOff,
                size: size,
                backgroundColor: iconBackgroundColor,
                foregroundColor: iconForegroundColor,
                active: viewModel.callSettings.videoOn
            ) {
                if permissionChecker.cameraPermissionStatus == .denied {
                    permissionChecker.openAppSettings()
                } else {
                    viewModel.toggleCameraEnabled()
                }
            }

            if permissionChecker.cameraPermissionStatus == .denied {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: size * 0.35, height: size * 0.35)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)

                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: size * 0.35))
                }
                .offset(x: size * 0.35, y: -size * 0.35)
            }
        }
        .modifier(ShadowModifier())
        .onAppear {
            permissionChecker.checkCameraPermission()
        }
    }
}

/// Custom implementation of MicrophoneIconView with customizable colors
public struct CustomMicrophoneIconView: View {
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    @ObservedObject private var permissionChecker = PermissionChecker.shared

    @ObservedObject var viewModel: CallViewModel
    let iconBackgroundColor: Color
    let iconForegroundColor: Color
    let size: CGFloat

    public init(
        viewModel: CallViewModel,
        iconBackgroundColor: Color = .white,
        iconForegroundColor: Color = .black,
        size: CGFloat = 44
    ) {
        self.viewModel = viewModel
        self.iconBackgroundColor = iconBackgroundColor
        self.iconForegroundColor = iconForegroundColor
        self.size = size
    }

    public var body: some View {
        ZStack {
            CallControlIcon(
                icon: viewModel.callSettings.audioOn
                    ? images.micTurnOn
                    : images.micTurnOff,
                size: size,
                backgroundColor: iconBackgroundColor,
                foregroundColor: iconForegroundColor,
                active: viewModel.callSettings.audioOn
            ) {
                if permissionChecker.microphonePermissionStatus == .denied {
                    permissionChecker.openAppSettings()
                } else {
                    viewModel.toggleMicrophoneEnabled()
                }
            }

            if permissionChecker.microphonePermissionStatus == .denied {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: size * 0.35, height: size * 0.35)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)

                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: size * 0.35))
                }
                .offset(x: size * 0.35, y: -size * 0.35)
            }
        }
        .modifier(ShadowModifier())
        .onAppear {
            permissionChecker.checkMicrophonePermission()
        }
    }
}

/// Helper struct for creating call control icons with consistent styling
public struct CallControlIcon: View {
    let icon: Image
    let size: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let active: Bool
    let action: () -> Void

    public var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: size, height: size)

                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.5, height: size * 0.5)
                    .foregroundColor(foregroundColor)
            }
        }
    }
}

import StreamVideo
import StreamVideoSwiftUI
import SwiftUICore
import UIKit
import SwiftUI

@available(iOS 14.0, *)
struct VideoCallView: View {
    @StateObject var viewModel = CallViewModel()
    @StateObject var uiStateViewModel = CallUIStateViewModel()
    @State private var hasSubscribed = false
    @ObservedObject private var permissionChecker = PermissionChecker.shared
    @State private var showPermissionAlert = false

    private var callId: String
    private var currentUser: User
    private var preferredExtension: String?
    var onCallEndedHandler: (() -> Void)?

    init(
        callId: String, currentUser: User, preferredExtension: String?,
        onCallEnded: (() -> Void)? = nil
    ) {
        self.callId = callId
        self.currentUser = currentUser
        self.preferredExtension = preferredExtension
        self.onCallEndedHandler = onCallEnded
    }

    var body: some View {
        VStack {
            CallContainer(
                viewFactory: CustomViewFactory(
                    preferredExtension: self.preferredExtension ?? "",
                    uiStateViewModel: uiStateViewModel,
                    onCallEnded: onCallEndedHandler
                ),
                viewModel: viewModel
            )
        }
        .edgesIgnoringSafeArea(hideLayoutMenu ? .all : [])
        .onAppear {
            // Request permissions when view appears
            permissionChecker.requestPermissionsIfPossible()

            // Check for denied permissions (with a slight delay to allow time for permission dialogs)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if permissionChecker.cameraPermissionStatus == .denied ||
                    permissionChecker.microphonePermissionStatus == .denied {
                    showPermissionAlert = true
                }
            }

            Task {
                do {
                    try await viewModel.call?.update(
                        settingsOverride: CallSettingsRequest(
                            audio: AudioSettingsRequest(
                                accessRequestEnabled: true,
                                defaultDevice: .speaker,
                                micDefaultOn: true,
                                noiseCancellation: nil,
                                opusDtxEnabled: true,
                                redundantCodingEnabled: true,
                                speakerDefaultOn: true
                            ),
                            screensharing: ScreensharingSettingsRequest(
                                accessRequestEnabled: true,
                                enabled: true,
                                targetResolution: TargetResolution(
                                    height: 720,
                                    width: 1280
                                )
                            ),
                            video: VideoSettingsRequest(
                                accessRequestEnabled: true,
                                cameraDefaultOn: true,
                                cameraFacing: .front,
                                enabled: true,
                                targetResolution: TargetResolution(
                                    bitrate: 1500000,
                                    height: 720,
                                    width: 1280
                                )
                            )
                        ))

                    viewModel.startCall(
                        callType: .default, callId: callId, members: [])
                } catch {
                    print("Error updating settings or starting call: \(error)")
                }
            }
        }
        .onChange(of: viewModel.call?.state.isInitialized) { newCall in
            if newCall != nil && !hasSubscribed {
                hasSubscribed = true
            }
        }
        .alert(isPresented: $showPermissionAlert) {
            createPermissionAlert()
        }
    }

    private func createPermissionAlert() -> Alert {
        var message = "To use the full features of this video call:"

        if permissionChecker.cameraPermissionStatus == .denied {
            message += "\n• Camera access is needed for video"
        }

        if permissionChecker.microphonePermissionStatus == .denied {
            message += "\n• Microphone access is needed for audio"
        }

        return Alert(
            title: Text("Permission Required"),
            message: Text(message),
            primaryButton: .default(Text("Settings")) {
                permissionChecker.openAppSettings()
            },
            secondaryButton: .cancel()
        )
    }

    private var isFullScreen: Bool {
        uiStateViewModel.isFullScreen
    }

    private var isOtherUserScreenSharing: Bool {
        let screenSharingSession = viewModel.call?.state.screenSharingSession
        return screenSharingSession != nil
            && viewModel.call?.state.isCurrentUserScreensharing == false
    }

    private var hideLayoutMenu: Bool {
        isFullScreen && !isOtherUserScreenSharing
    }
}

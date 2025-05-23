import AVFoundation
import StreamVideo
import StreamVideoSwiftUI
import SwiftUI

public struct CustomCallTopView: View {

    @Injected(\.colors) var colors
    @Injected(\.images) var images

    @ObservedObject var viewModel: CallViewModel
    @ObservedObject var uiStateViewModel: CallUIStateViewModel
    @State var sharingPopupDismissed = false
    @State private var currentAudioRoute: AVAudioSession.Port =
        AVAudioSession.sharedInstance().currentRoute.outputs.first?.portType
        ?? .builtInReceiver

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    init(viewModel: CallViewModel, uiStateViewModel: CallUIStateViewModel) {
        self.viewModel = viewModel
        self.uiStateViewModel = uiStateViewModel
    }

    public var body: some View {
        Group {
            ZStack {
                HStack {
                    ToggleCameraIconView(viewModel: viewModel)
                    Spacer()
                }
                HStack(alignment: .center) {
                    Spacer()

                    CallDurationView(viewModel)

                    Spacer()
                }

                HStack {
                    Spacer()

                    Button {
                        Task {
                            try await viewModel.call?.speaker
                                .toggleSpeakerPhone()
                            if let output = AVAudioSession.sharedInstance()
                                .currentRoute.outputs.first {
                                currentAudioRoute = output.portType
                            }
                        }
                    } label: {
                        ZStack {
                            Image(systemName: audioIcon(for: currentAudioRoute))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, horizontalSizeClass == .regular ? 8 : 0)
            .frame(maxWidth: .infinity)
            .onReceive(
                NotificationCenter.default.publisher(
                    for: AVAudioSession.routeChangeNotification)
            ) { _ in
                if let output = AVAudioSession.sharedInstance().currentRoute
                    .outputs.first {
                    currentAudioRoute = output.portType
                }
            }
        }
    }

    private func audioIcon(for portType: AVAudioSession.Port) -> String {
        switch portType {
        case .builtInReceiver:
            return "phone.fill"
        case .builtInSpeaker:
            return "speaker.wave.2.fill"
        case .headphones:
            return "airpods"
        case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE:
            return "airpods"
        default:
            return "questionmark"
        }
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

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}

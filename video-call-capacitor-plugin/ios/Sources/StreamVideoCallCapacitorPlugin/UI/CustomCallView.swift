//
//  CustomCallView.swift
//  StreamVideoCallCapacitor
//
//  Created by Stanislav Drehval on 13.02.2025.
//

import StreamVideo
import StreamWebRTC
import SwiftUI
import StreamVideoSwiftUI

public struct CustomCallView<Factory: ViewFactory>: View {

    @Injected(\.streamVideo) var streamVideo
    @Injected(\.images) var images
    @Injected(\.colors) var colors

    var viewFactory: Factory
    @ObservedObject var viewModel: CallViewModel
    @ObservedObject var uiStateViewModel: CallUIStateViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    init(viewFactory: Factory, viewModel: CallViewModel, uiStateViewModel: CallUIStateViewModel) {
        self.viewFactory = viewFactory
        self.viewModel = viewModel
        self.uiStateViewModel = uiStateViewModel
    }

    var scaleFactorX: CGFloat {
        switch (horizontalSizeClass, uiStateViewModel.isFullScreen) {
        case (.regular, true):
            return 0.23
        case (.regular, false):
            return 0.20
        case (.compact, true):
            return 0.32
        case (.compact, false):
            return 0.33
        default:
            return 0.33
        }
    }

    var scaleFactorY: CGFloat {
        switch (horizontalSizeClass, uiStateViewModel.isFullScreen) {
        case (.regular, true):
            return 0.25
        case (.regular, false):
            return 0.30
        case (.compact, true):
            return 0.22
        case (.compact, false):
            return 0.28
        default:
            return 0.33
        }
    }

    public var body: some View {
        ZStack {
            DefaultBackgroundGradient()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: hideLayoutMenu ? 0 : 8) {

                if !hideLayoutMenu {
                    viewFactory
                        .makeCallTopView(viewModel: viewModel)
                        .transition(.move(edge: .top))
                        .presentParticipantEventsNotification(viewModel: viewModel)
                }

                GeometryReader { videoFeedProxy in
                    ZStack {
                        contentView(videoFeedProxy.frame(in: .global))

                        cornerDraggableView(videoFeedProxy)
                    }
                }
                .padding([.leading, .trailing], hideLayoutMenu ? 0 : 8)

                if !hideLayoutMenu {
                    viewFactory.makeCallControlsView(viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                        .opacity(viewModel.hideUIElements ? 0 : 1)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: hideLayoutMenu)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            .enablePictureInPicture(viewModel.isPictureInPictureEnabled)
            .presentParticipantListView(viewModel: viewModel, viewFactory: viewFactory)
        }
    }

    @ViewBuilder
    private func contentView(_ availableFrame: CGRect) -> some View {
        if viewModel.localVideoPrimary, viewModel.participantsLayout == .grid {
            localVideoView(bounds: availableFrame)
                .accessibility(identifier: "localVideoView")
        } else if
            let screenSharingSession = viewModel.call?.state.screenSharingSession,
            viewModel.call?.state.isCurrentUserScreensharing == false {
            viewFactory.makeScreenSharingView(
                viewModel: viewModel,
                screensharingSession: screenSharingSession,
                availableFrame: availableFrame
            )
        } else {
            participantsView(bounds: availableFrame)
        }
    }

    private var shouldShowDraggableView: Bool {
        (viewModel.call?.state.screenSharingSession == nil || viewModel.call?.state.isCurrentUserScreensharing == true)
            && viewModel.participantsLayout == .grid
            && viewModel.participants.count <= 3
    }

    @ViewBuilder
    private func cornerDraggableView(_ proxy: GeometryProxy) -> some View {
        if shouldShowDraggableView {
            CustomCornerDraggableView(
                scaleFactorX: scaleFactorX,
                scaleFactorY: scaleFactorY,
                content: { cornerDraggableViewContent($0) },
                proxy: proxy,
                onTap: {
                    withAnimation {
                        if participants.count == 1 {
                            viewModel.localVideoPrimary.toggle()
                        }
                    }
                }
            )
            .accessibility(identifier: "cornerDraggableView")
            .opacity(viewModel.hideUIElements ? 0 : 1)
            .padding()
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func cornerDraggableViewContent(_ bounds: CGRect) -> some View {
        if viewModel.localVideoPrimary {
            minimizedView(bounds: bounds)
        } else {
            localVideoView(bounds: bounds)
        }
    }

    @ViewBuilder
    private func minimizedView(bounds: CGRect) -> some View {
        if let firstParticipant = viewModel.participants.first {
            viewFactory.makeVideoParticipantView(
                participant: firstParticipant,
                id: firstParticipant.id,
                availableFrame: bounds,
                contentMode: .scaleAspectFit,
                customData: [:],
                call: viewModel.call
            )
            .modifier(
                viewFactory.makeVideoCallParticipantModifier(
                    participant: firstParticipant,
                    call: viewModel.call,
                    availableFrame: bounds,
                    ratio: bounds.width / bounds.height,
                    showAllInfo: true
                )
            )
            .accessibility(identifier: "minimizedParticipantView")
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func localVideoView(bounds: CGRect) -> some View {
        if let localParticipant = viewModel.localParticipant {
            LocalVideoView(
                viewFactory: viewFactory,
                participant: localParticipant,
                callSettings: viewModel.callSettings,
                call: viewModel.call,
                availableFrame: bounds
            )
            .onTapGesture {
                uiStateViewModel.isFullScreen.toggle()
            }
            .modifier(viewFactory.makeLocalParticipantViewModifier(
                localParticipant: localParticipant,
                callSettings: .constant(viewModel.callSettings),
                call: viewModel.call
            ))
        } else {
            EmptyView()
        }
    }

    private func participantsView(bounds: CGRect) -> some View {
        viewFactory.makeVideoParticipantsView(
            viewModel: viewModel,
            availableFrame: bounds,
            onChangeTrackVisibility: viewModel.changeTrackVisibility(for:isVisible:)
        )
        .onTapGesture {
            uiStateViewModel.isFullScreen.toggle()
        }
    }

    private var participants: [CallParticipant] {
        viewModel.participants
    }

    private var isFullScreen: Bool {
        uiStateViewModel.isFullScreen
    }

    private var isOtherUserScreenSharing: Bool {
        let screenSharingSession = viewModel.call?.state.screenSharingSession
        return screenSharingSession != nil && viewModel.call?.state.isCurrentUserScreensharing == false
    }

    private var hideLayoutMenu: Bool {
        isFullScreen && !isOtherUserScreenSharing
    }

}

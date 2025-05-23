//
//  CustomWaitingLocalUserView.swift
//  StreamVideoCallCapacitor
//
//  Created by Stanislav Drehval on 25.02.2025.
//

import SwiftUICore
import StreamVideo
import StreamVideoSwiftUI

public struct CustomWaitingLocalUserView<Factory: ViewFactory>: View {

    @Injected(\.appearance) var appearance

    @ObservedObject var viewModel: CallViewModel
    var viewFactory: Factory
    @ObservedObject var uiStateViewModel: CallUIStateViewModel

    init(viewModel: CallViewModel, viewFactory: Factory, uiStateViewModel: CallUIStateViewModel) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory
        self.uiStateViewModel = uiStateViewModel
    }

    public var body: some View {
        ZStack {
            DefaultBackgroundGradient()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: uiStateViewModel.isFullScreen ? 0 : 8) {

                if !uiStateViewModel.isFullScreen {
                    viewFactory.makeCallTopView(viewModel: viewModel)
                        .transition(.move(edge: .top))
                        .opacity(viewModel.callingState == .reconnecting ? 0 : 1)
                }

                Group {
                    if let localParticipant = viewModel.localParticipant {
                        GeometryReader { proxy in
                            LocalVideoView(
                                viewFactory: viewFactory,
                                participant: localParticipant,
                                idSuffix: "waiting",
                                callSettings: viewModel.callSettings,
                                call: viewModel.call,
                                availableFrame: proxy.frame(in: .global)
                            )
                            .modifier(viewFactory.makeLocalParticipantViewModifier(
                                localParticipant: localParticipant,
                                callSettings: .constant(viewModel.callSettings),
                                call: viewModel.call
                            ))
                        }
                    } else {
                        Spacer()
                    }
                }
                .padding(.horizontal, uiStateViewModel.isFullScreen ? 0 : 8)
                .opacity(viewModel.callingState == .reconnecting ? 0 : 1)

                if !uiStateViewModel.isFullScreen {
                    viewFactory.makeCallControlsView(viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                        .opacity(viewModel.callingState == .reconnecting ? 0 : 1)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: uiStateViewModel.isFullScreen)
            .presentParticipantListView(viewModel: viewModel, viewFactory: viewFactory)
        }
    }
}

struct DefaultBackgroundGradient: View {

    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 60 / 255, green: 64 / 255, blue: 72 / 255),
                Color(red: 30 / 255, green: 33 / 255, blue: 36 / 255)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

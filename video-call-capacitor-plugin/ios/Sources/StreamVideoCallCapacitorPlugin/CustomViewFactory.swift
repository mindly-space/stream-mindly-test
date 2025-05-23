import StreamVideo
import StreamVideoSwiftUI
//
//  CustomViewFactory.swift
//  StreamVideoCallCapacitor
//
//  Created by Stanislav Drehval on 23.01.2025.
//
import SwiftUI

class CustomViewFactory: ViewFactory {
    let preferredExtension: String
    let uiStateViewModel: CallUIStateViewModel
    var onCallEndedHandler: (() -> Void)?

    init(
        preferredExtension: String, uiStateViewModel: CallUIStateViewModel,
        onCallEnded: (() -> Void)? = nil
    ) {
        self.preferredExtension = preferredExtension
        self.uiStateViewModel = uiStateViewModel
        self.onCallEndedHandler = onCallEnded
    }

    func makeCallTopView(viewModel: CallViewModel) -> some View {
        CustomCallTopView(
            viewModel: viewModel,
            uiStateViewModel: uiStateViewModel
        )
    }

    func makeCallControlsView(viewModel: CallViewModel) -> some View {
        CustomCallControlsView(
            viewModel: viewModel,
            preferredExtension: preferredExtension,
            uiStateViewModel: uiStateViewModel,
            onCallEnded: onCallEndedHandler
        )
    }

    func makeVideoParticipantView(
        participant: CallParticipant,
        id: String,
        availableFrame: CGRect,
        contentMode: UIView.ContentMode,
        customData: [String: RawJSON],
        call: Call?
    ) -> some View {
        CustomParticipantView(
            participant: participant,
            id: id,
            availableFrame: availableFrame,
            contentMode: .scaleAspectFit,
            customData: customData,
            call: call
        )
    }

    func makeVideoCallParticipantModifier(
        participant: CallParticipant,
        call: Call?,
        availableFrame: CGRect,
        ratio: CGFloat,
        showAllInfo: Bool
    ) -> some ViewModifier {
        CustomVideoCallParticipantModifier(
            participant: participant,
            call: call,
            availableFrame: availableFrame,
            ratio: ratio,
            showAllInfo: showAllInfo
        )
    }

    func makeLocalParticipantViewModifier(
        localParticipant: CallParticipant,
        callSettings: Binding<CallSettings>,
        call: Call?
    ) -> some ViewModifier {
        CustomLocalParticipantViewModifierIOS13(
            localParticipant: localParticipant,
            call: call,
            callSettings: callSettings,
            showAllInfo: true,
            uiStateViewModel: uiStateViewModel
        )
    }

    func makeCallView(viewModel: CallViewModel) -> some View {
        CustomCallView(
            viewFactory: self,
            viewModel: viewModel,
            uiStateViewModel: uiStateViewModel
        )
    }

    func makeWaitingLocalUserView(viewModel: CallViewModel) -> some View {
        CustomWaitingLocalUserView(
            viewModel: viewModel,
            viewFactory: self,
            uiStateViewModel: uiStateViewModel
        )
    }
}

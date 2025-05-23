//
//  Custom.swift
//  StreamVideoCallCapacitor
//
//  Created by Stanislav Drehval on 12.02.2025.
//

import Foundation
import StreamVideo
import SwiftUI
import StreamVideoSwiftUI

@available(iOS, introduced: 13, obsoleted: 14)
public struct CustomLocalParticipantViewModifierIOS13: ViewModifier {

    private let localParticipant: CallParticipant
    private var call: Call?
    private var showAllInfo: Bool
    @BackportStateObject private var microphoneChecker: MicrophoneChecker
    @Binding private var callSettings: CallSettings
    private var decorations: Set<VideoCallParticipantDecoration>
    @ObservedObject var uiStateViewModel: CallUIStateViewModel

    init(
        localParticipant: CallParticipant,
        call: Call?,
        callSettings: Binding<CallSettings>,
        showAllInfo: Bool = false,
        decorations: [VideoCallParticipantDecoration] = VideoCallParticipantDecoration.allCases,
        uiStateViewModel: CallUIStateViewModel
    ) {
        self.localParticipant = localParticipant
        self.call = call
        _microphoneChecker = .init(wrappedValue: .init())
        _callSettings = callSettings
        self.showAllInfo = showAllInfo
        self.decorations = .init(decorations)
        self.uiStateViewModel = uiStateViewModel
    }

    public func body(content: Content) -> some View {
        content
            .overlay(
                BottomView {
                    HStack {
                        ParticipantMicrophoneCheckView(
                            audioLevels: microphoneChecker.audioLevels,
                            microphoneOn: callSettings.audioOn,
                            isSilent: microphoneChecker.isSilent,
                            isPinned: localParticipant.isPinned
                        )

                        if showAllInfo {
                            Spacer()
                            ConnectionQualityIndicator(
                                connectionQuality: localParticipant.connectionQuality
                            )
                        }
                    }
                    .padding(.bottom, 2)
                }
                .padding(.all, showAllInfo ? 16 : 8)
                .onAppear { Task { await microphoneChecker.startListening() } }
                .onDisappear { Task { await microphoneChecker.stopListening() } }
            )
            .applyDecorationModifierIfRequired(
                VideoCallParticipantSpeakingModifier(participant: localParticipant, participantCount: participantCount),
                decoration: .speaking,
                availableDecorations: decorations
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .clipped()
            .onTapGesture {
                if participantCount == 1 {
                    uiStateViewModel.isFullScreen.toggle()
                }
            }
    }

    @MainActor
    private var participantCount: Int {
        call?.state.participants.count ?? 0
    }
}

internal struct ParticipantMicrophoneCheckView: View {

    var audioLevels: [Float]
    var microphoneOn: Bool
    var isSilent: Bool
    var isPinned: Bool

    var body: some View {
        MicrophoneCheckView(
            audioLevels: audioLevels,
            microphoneOn: microphoneOn,
            isSilent: isSilent,
            isPinned: isPinned
        )
        .accessibility(identifier: "microphoneCheckView")
    }
}

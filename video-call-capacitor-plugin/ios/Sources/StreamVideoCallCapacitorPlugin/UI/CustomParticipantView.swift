//
//  CustomParticipantsView.swift
//  StreamVideoCallCapacitor
//
//  Created by Stanislav Drehval on 12.02.2025.
//

import StreamVideo
import SwiftUI
import StreamVideoSwiftUI

public struct CustomParticipantView: View {

    @Injected(\.images) var images
    @Injected(\.streamVideo) var streamVideo

    let participant: CallParticipant
    var id: String
    var availableFrame: CGRect
    var contentMode: UIView.ContentMode
    var edgesIgnoringSafeArea: Edge.Set
    var customData: [String: RawJSON]
    var call: Call?

    @State private var isUsingFrontCameraForLocalUser: Bool = false

    public init(
        participant: CallParticipant,
        id: String? = nil,
        availableFrame: CGRect,
        contentMode: UIView.ContentMode,
        edgesIgnoringSafeArea: Edge.Set = .all,
        customData: [String: RawJSON],
        call: Call?
    ) {
        self.participant = participant
        self.id = id ?? participant.id
        self.availableFrame = availableFrame
        self.contentMode = contentMode
        self.edgesIgnoringSafeArea = edgesIgnoringSafeArea
        self.customData = customData
        self.call = call
    }

    public var body: some View {
        withCallSettingsObservation {
            VideoRendererView(
                id: id,
                size: availableFrame.size,
                contentMode: .scaleAspectFit,
                showVideo: showVideo,
                handleRendering: { [weak call, participant] view in
                    guard call != nil else { return }
                    view.handleViewRendering(for: participant) { [weak call] size, participant in
                        Task { [weak call] in
                            await call?.updateTrackSize(size, for: participant)
                        }
                    }
                }
            )
        }
        .opacity(showVideo ? 1 : 0)
        .edgesIgnoringSafeArea(edgesIgnoringSafeArea)
        .accessibility(identifier: "callParticipantView")
        .streamAccessibility(value: showVideo ? "1" : "0")
        .overlay(
            CallParticipantImageView(
                id: participant.id,
                name: participant.name,
                imageURL: participant.profileImageURL
            )
            .opacity(showVideo ? 0 : 1)
        )
        .padding(0)
    }

    private var showVideo: Bool {
        participant.shouldDisplayTrack || customData["videoOn"]?.boolValue == true
    }

    @MainActor
    @ViewBuilder
    private func withCallSettingsObservation(
        @ViewBuilder _ content: () -> some View
    ) -> some View {
        if participant.id == streamVideo.state.activeCall?.state.localParticipant?.id {
            content()
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .onReceive(call?.state.$callSettings) { self.isUsingFrontCameraForLocalUser = $0.cameraPosition == .front }
        } else {
            content()
        }
    }
}

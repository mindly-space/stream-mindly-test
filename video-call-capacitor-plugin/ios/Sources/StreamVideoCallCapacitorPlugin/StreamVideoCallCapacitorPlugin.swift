import Capacitor
import StreamVideoSwiftUI
import SwiftUI
import Foundation
import StreamVideo

@objc(StreamVideoCallCapacitorPlugin)
public class StreamVideoCallCapacitorPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "StreamVideoCallCapacitorPlugin"
    public let jsName = "StreamVideoCallCapacitor"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "initializeVideoCall", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "joinCall", returnType: CAPPluginReturnPromise)
    ]

    private var client: StreamVideo?
    private var preferredExtension: String?
    private var currentUser: User?

    @objc func initializeVideoCall(_ call: CAPPluginCall) {
        print("[StreamVideoCall]: Call initializeVideoCall")

        guard let apiKey = call.getString("apiKey") else {
            print( "[StreamVideoCall]: API Key is required")
            call.reject("[StreamVideoCall]: API Key is required")
            return
        }

        guard let token = call.getString("token") else {
            print( "[StreamVideoCall]: token is required")
            call.reject("[StreamVideoCall]: token is required")
            return
        }

        guard let userDict = call.getObject("user") else {
            print( "[StreamVideoCall]: user is required")
            call.reject("[StreamVideoCall]: user is required")
            return
        }

        // Convert string to dictionary first
        guard let userId = userDict["id"] as? String,
              let userName = userDict["name"] as? String
        else {
            print( "[StreamVideoCall]: Invalid user information" )
            call.reject("[StreamVideoCall]: Invalid user information")
            return
        }

        if call.getString("preferredExtension") != nil {
            self.preferredExtension = call.getString("preferredExtension")
        }

        let userImageURL = URL(string: (userDict["imageURL"] as? String) ?? "")

        let user = User(id: userId, name: userName, imageURL: userImageURL)

        self.currentUser = user

        client = StreamVideo(
            apiKey: apiKey,
            user: user,
            token: .init(stringLiteral: token)
        )

        if client == nil {
            print( "[StreamVideoCall]: Failed to initialize Stream client" )
            call.reject("[StreamVideoCall]: Failed to initialize Stream client")
            return
        }

        print("[StreamVideoCall]: IOS Call initializeVideoCall resolve")
        call.resolve()
    }

    @objc func joinCall(_ call: CAPPluginCall) {
        print( "[StreamVideoCall]: Call joinCall")

        DispatchQueue.main.async {
            guard let streamClient = self.client else {
                print( "[StreamVideoCall]: Invalid call client")
                call.reject("[StreamVideoCall]: Invalid call client")
                return
            }

            guard let callId = call.getString("callId") else {
                print( "[StreamVideoCall]: Call id not found")
                call.reject("[StreamVideoCall]: Call id not found")
                return
            }

            guard let currentUser = self.currentUser else {
                print("[StreamVideoCall]: Current user not initialized")
                call.reject("[StreamVideoCall]: Current user not initialized")
                return
            }

            let hostingController: UIHostingController<AnyView>
            if #available(iOS 14.0, *) {
                let callView = VideoCallView(
                    callId: callId,
                    currentUser: currentUser,
                    preferredExtension: self.preferredExtension,
                    onCallEnded: { [weak self] in

                        self?.notifyListeners("callEnded", data: ["callId": callId])

                        if let call = streamClient.state.activeCall {
                            call.leave()
                        }

                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let topViewController = scene.windows.first?.rootViewController {
                            topViewController.dismiss(animated: true)
                        }
                    }
                )
                hostingController = UIHostingController(rootView: AnyView(callView))
            } else {
                let callView = NoAvailabelView()
                hostingController = UIHostingController(rootView: AnyView(callView))
            }

            hostingController.modalPresentationStyle = .fullScreen
            hostingController.view.backgroundColor = .black

            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topViewController = scene.windows.first?.rootViewController {
                topViewController.present(hostingController, animated: true)

                self.notifyListeners("callJoined", data: [
                    "callId": callId,
                    "userId": currentUser.id
                ])

                call.resolve()
            } else {
                print( "[StreamVideoCall]: No window scene found")
                call.reject("[StreamVideoCall]: No window scene found")
            }
        }
    }
}

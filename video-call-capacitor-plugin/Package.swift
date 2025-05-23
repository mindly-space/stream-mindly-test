// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StreamVideoCallCapacitor",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "StreamVideoCallCapacitor",
            targets: ["StreamVideoCallCapacitorPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main"),
        .package(url: "https://github.com/GetStream/stream-video-swift.git", branch: "1.22.2")
    ],
    targets: [
        .target(
            name: "StreamVideoCallCapacitorPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "StreamVideo", package: "stream-video-swift"),
                .product(name: "StreamVideoSwiftUI", package: "stream-video-swift")
            ],
            path: "ios/Sources/StreamVideoCallCapacitorPlugin"),
        .testTarget(
            name: "StreamVideoCallCapacitorPluginTests",
            dependencies: ["StreamVideoCallCapacitorPlugin"],
            path: "ios/Tests/StreamVideoCallCapacitorPluginTests")
    ]
)

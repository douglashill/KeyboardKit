// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "KeyboardKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "KeyboardKit",
            targets: ["KeyboardKit"]
        ),
    ],
    targets: [
        .target(
            name: "KeyboardKit",
            path: "KeyboardKit"
        ),
        .testTarget(
            name: "KeyboardKitTests",
            dependencies: ["KeyboardKit"],
            path: "KeyboardKitTests"
        ),
    ]
)

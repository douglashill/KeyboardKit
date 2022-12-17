// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "KeyboardKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "KeyboardKit",
            targets: ["KeyboardKit"]
        ),
    ],
    targets: [
        .target(
            name: "KeyboardKitObjC",
            path: "KeyboardKit/ObjC",
            exclude: ["ResponderChainDebugging.m"],
            publicHeadersPath: ""
        ),
        .target(
            name: "KeyboardKit",
            dependencies: ["KeyboardKitObjC"],
            path: "KeyboardKit",
            exclude: ["Info.plist", "ObjC", "UpdateLocalisedStringKeys.swift", "Documentation.docc"]
        ),
        .testTarget(
            name: "KeyboardKitTests",
            dependencies: ["KeyboardKit"],
            path: "KeyboardKitTests",
            exclude: ["Info.plist"]
        ),
    ]
)

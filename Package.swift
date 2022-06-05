// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "KeyboardKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
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

// This isn’t actually a dependency of KeyboardKit, but Swift Package Index needs this to generate documentation, so we have to add it for everyone.
// https://blog.swiftpackageindex.com/posts/auto-generating-auto-hosting-and-auto-updating-docc-documentation/
#if swift(>=5.6)
  package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
  )
#endif

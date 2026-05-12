// swift-tools-version: 6.2
// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import PackageDescription

let package = Package(
    name: "spfk-metadata-base",
    defaultLocalization: "en",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(
            name: "SPFKMetadataBase",
            targets: ["SPFKMetadataBase"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ryanfrancesconi/spfk-audio-base", from: "1.0.1"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-utils", from: "1.0.2"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-testing", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "SPFKMetadataBase",
            dependencies: [
                .product(name: "SPFKAudioBase", package: "spfk-audio-base"),
                .product(name: "SPFKUtils", package: "spfk-utils"),
            ]
        ),
        .testTarget(
            name: "SPFKMetadataBaseTests",
            dependencies: [
                "SPFKMetadataBase",
                .product(name: "SPFKTesting", package: "spfk-testing"),
            ]
        ),
    ]
)

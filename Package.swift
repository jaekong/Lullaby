// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lullaby",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Lullaby",
            targets: ["Lullaby"]),
        .library(
            name: "LullabyMusic",
            targets: ["LullabyMusic"]),
        .library(
            name: "LullabySoundIOEngine",
            targets: ["LullabySoundIOEngine"]),
        .library(
            name: "LullabyMiniAudioEngine",
            targets: ["LullabyMiniAudioEngine"])
    ],
    dependencies: [
        .package(url: "https://github.com/thara/SoundIO.git", from: "0.3.2"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "0.0.5"))
//        .package(url: "https://github.com/apple/swift-numerics.git", .upToNextMajor(from: "0.1.0"))
    ],
    targets: [
        .target(
            name: "Lullaby",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .target(name: "LullabyMusic")
            ]
        ),
        .target(
            name: "LullabyMusic"
        ),
        .target(
            name: "LullabySoundIOEngine",
            dependencies: [
                .product(name: "SoundIO", package: "SoundIO"),
                .product(name: "Collections", package: "swift-collections"),
                .target(name: "Lullaby")
            ],
            linkerSettings: [.unsafeFlags(["-L/usr/local/lib"])]
        ),
        .target(
            name: "CMiniAudio",
            dependencies: [],
            path: "Sources/CMiniAudio",
            cSettings: [
                .define("MINIAUDIO_IMPLEMENTATION")
            ]
        ),
        .target(
            name: "LullabyMiniAudioEngine",
            dependencies: [
                .target(name: "CMiniAudio"),
                .target(name: "Lullaby")
            ]
        ),
        .testTarget(
            name: "LullabyTests",
            dependencies: [
                .target(name: "Lullaby"),
                .target(name: "LullabySoundIOEngine"),
                .target(name: "LullabyMiniAudioEngine")
            ])
    ]
)

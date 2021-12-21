// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lullaby",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Lullaby",
            targets: ["Lullaby"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/thara/SoundIO.git", from: "0.3.2"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "0.0.5"))
//        .package(url: "https://github.com/SammySmallman/OSCKit", .upToNextMajor(from: "3.0.1"))
//        .package(url: "https://github.com/apple/swift-numerics.git", .upToNextMajor(from: "0.1.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Lullaby",
            dependencies: [
                .product(name: "SoundIO", package: "SoundIO"),
                .product(name: "Collections", package: "swift-collections"),
                .target(name: "LullabyMusic")
            ]
//            linkerSettings: [.unsafeFlags(["-L/usr/local/lib"])]
        ),
        .target(
            name: "LullabyMusic"
        ),
        .testTarget(
            name: "LullabyTests",
            dependencies: [
                .target(name: "Lullaby")
//                .product(name: "OSCKit", package: "OSCKit")
            ]),
    ]
)

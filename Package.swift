// swift-tools-version: 5.10

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription

let package = Package(
    name: "GameOfLife.swiftpm",
    platforms: [
        .iOS("16.1")
    ],
    products: [
        .library(
            name: "GameOfLife",
            targets: ["GameOfLife"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections", branch: "main"),
    ],
    targets: [
        .target(
            name: "GameOfLife",
            dependencies: [
                .product(name: "BitCollections", package: "swift-collections")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ExistentialAny"),
            ]
        ),
        .executableTarget(
            name: "AppModule",
            dependencies: [
                "GameOfLife",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-warn-long-function-bodies=100"], .when(configuration: .debug)),
                .unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=100"], .when(configuration: .debug)),
                .enableExperimentalFeature("StrictConcurrency"),
                .unsafeFlags(["-Xfrontend", "-enable-actor-data-race-checks"]),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ExistentialAny"),
            ]
        ),
    ]
)

#if canImport(AppleProductTypes)
    import AppleProductTypes

    package.products += [
        .iOSApplication(
            name: "Game of Life",
            targets: ["AppModule"],
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .gamepad),
            accentColor: .presetColor(.orange),
            supportedDeviceFamilies: [
                .pad,
                .phone,
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad])),
            ],
            appCategory: .simulationGames
        )
    ]
#endif

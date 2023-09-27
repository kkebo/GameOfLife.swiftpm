// swift-tools-version: 5.9

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
        .package(url: "https://github.com/apple/swift-async-algorithms", "1.0.0-beta.1"..<"1.1.0"),
        .package(url: "https://github.com/apple/swift-collections", branch: "origin/release/1.1"),
    ],
    targets: [
        .target(
            name: "GameOfLife",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"]),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
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
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"]),
                .unsafeFlags(["-Xfrontend", "-enable-actor-data-race-checks"]),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
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

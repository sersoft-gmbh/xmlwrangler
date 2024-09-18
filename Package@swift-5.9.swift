// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: Array<SwiftSetting> = [
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
    .enableExperimentalFeature("AccessLevelOnImport"),
//    .enableExperimentalFeature("VariadicGenerics"),
]

let package = Package(
    name: "xmlwrangler",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "XMLWrangler",
            targets: ["XMLWrangler"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "XMLWrangler",
            swiftSettings: swiftSettings),
        .testTarget(
            name: "XMLWranglerTests",
            dependencies: ["XMLWrangler"],
            swiftSettings: swiftSettings),
    ]
)

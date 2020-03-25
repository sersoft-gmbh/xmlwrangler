// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "XMLWrangler",
    products: [
        .library(name: "XMLWrangler", targets: ["XMLWrangler"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "SemVer", url: "https://github.com/sersoft-gmbh/semver.git", from: "2.3.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "XMLWrangler",
            dependencies: ["SemVer"],
            exclude: ["Supporting Files"]),
        .testTarget(
            name: "XMLWranglerTests",
            dependencies: ["XMLWrangler"],
            exclude: ["Supporting Files"]),
    ]
)

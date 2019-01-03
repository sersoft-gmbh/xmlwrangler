// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "XMLWrangler",
    products: [
        .library(name: "XMLWrangler", targets: ["XMLWrangler"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/sersoft-gmbh/semver.git", from: "2.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "XMLWrangler", dependencies: ["SemVer"]),
        .testTarget(name: "XMLWranglerTests", dependencies: ["XMLWrangler"]),
    ]
)

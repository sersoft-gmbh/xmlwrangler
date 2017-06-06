// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "XMLWrangler",
    dependencies: [
      .Package(url: "https://github.com/sersoft-gmbh/semver.git", majorVersion: 1)
   ]
)

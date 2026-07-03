// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "MathTypeset",
    products: [
        .library(
            name: "MathTypeset",
            targets: ["MathTypeset"],
        ),
    ],
    dependencies: [
        // Documentation tooling only; the MathTypeset library itself stays
        // dependency-free for consumers (plugins do not propagate).
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.3"),
    ],
    targets: [
        .target(
            name: "MathTypeset",
        ),
        .target(
            name: "MathTypesetDocumentation",
        ),
        .testTarget(
            name: "MathTypesetTests",
            dependencies: ["MathTypeset"],
        ),
    ],
)

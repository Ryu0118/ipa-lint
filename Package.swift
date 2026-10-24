// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "IPALint",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(name: "IPALint", targets: ["IPALint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.8.2"),
    ],
    targets: [
        .executableTarget(
            name: "IPALint",
            dependencies: ["IPALintCLI"]
        ),
        .target(
            name: "IPALintCLI",
            dependencies: [
                "IPALintKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(name: "IPALintKit"),
        .testTarget(
            name: "IPALintCLITests",
            dependencies: ["IPALintCLI"]
        ),
        .testTarget(
            name: "IPALintKitTests",
            dependencies: ["IPALintKit"]
        ),
    ]
)

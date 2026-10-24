// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "IPALint",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(name: "ipa-lint", targets: ["IPALint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.8.2"),
        .package(url: "https://github.com/Ryu0118/FileManagerProtocol", from: "0.1.0"),
        .package(url: "https://github.com/Ryu0118/ProcessRunning", from: "0.3.0"),
        .package(url: "https://github.com/swiftlang/swift-subprocess", from: "1.0.2"),
        .package(url: "https://github.com/jpsim/Yams", from: "6.2.2"),
    ],
    targets: [
        .executableTarget(
            name: "IPALint",
            dependencies: ["IPALintCLI"],
        ),
        .target(
            name: "IPALintCLI",
            dependencies: [
                "IPALintKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "FileManagerProtocol", package: "FileManagerProtocol"),
                .product(name: "ProcessRunning", package: "ProcessRunning"),
                .product(name: "Subprocess", package: "swift-subprocess"),
            ],
        ),
        .target(
            name: "IPALintKit",
            dependencies: [
                .product(name: "FileManagerProtocol", package: "FileManagerProtocol"),
                .product(name: "Yams", package: "Yams"),
            ],
        ),
        .testTarget(
            name: "IPALintCLITests",
            dependencies: ["IPALintCLI"],
        ),
        .testTarget(
            name: "IPALintKitTests",
            dependencies: ["IPALintKit"],
        ),
    ],
)

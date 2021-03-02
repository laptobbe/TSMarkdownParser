// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MarkdownParser",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "MarkdownParser",
            targets: ["MarkdownParser"]),
    ],
    targets: [
        .target(
            name: "MarkdownParser",
            dependencies: [],
            path: "TSMarkdownParser")
    ]
)

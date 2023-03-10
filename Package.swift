// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "networking",
    products: [
        .library(
            name: "networking",
            targets: ["networking"]),
    ],
    targets: [
        .target(
            name: "networking",
            dependencies: [],
            path: "./networking/module"),
    ]
)

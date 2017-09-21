// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Carting",
    products: [
        .library(name: "Carting", targets: ["CartingCore"]),
        ],
    targets: [
        .target(name: "Carting", dependencies: ["CartingCore"]),
        .target(name: "CartingCore")
        ]
)

// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Carting",
    products: [
        .library(name: "Carting", targets: ["Carting"]),
        ],
    targets: [
        .target(name: "Carting", path: "Sources/Carting"),
        .target(name: "CartingCore", path: "./Sources/CartingCore")
        ],
    swiftLanguageVersions: [4]
)

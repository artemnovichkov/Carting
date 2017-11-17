// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Carting",
    products: [
        .library(name: "Carting", targets: ["CartingCore"]),
        ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/files.git", from: "2.0.1"),
        .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "Carting", dependencies: ["CartingCore"]),
        .target(name: "CartingCore", dependencies: ["Files", "ShellOut"])
        ]
)

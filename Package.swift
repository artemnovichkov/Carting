// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Carting",
    products: [
        .executable(name: "Carting", targets: ["Carting"]),
        .library(name: "Carting", targets: ["CartingCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files.git", from: "3.0.0"),
        .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.0.0")
    ],
    targets: [
        .target(name: "Carting", dependencies: ["CartingCore"]),
        .target(name: "CartingCore", dependencies: ["Files", "ShellOut", "SPMUtility"])
    ]
)

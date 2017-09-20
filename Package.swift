// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Carting",
    targets: [
        .target(
            name: "Carting",
            dependencies: ["CartingCore"]),
        .target(
            name: "CartingCore",
            path: "./Sources/CartingCore"),
    ]
)

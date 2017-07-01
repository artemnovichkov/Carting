// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Carting",
    targets: [
        Target(
            name: "Carting",
            dependencies: ["CartingCore"]
        ),
        Target(name: "CartingCore")
    ]
)

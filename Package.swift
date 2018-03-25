// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftAddressInterpolation",
    products: [
        .executable(
            name: "Interpolate",
            targets: ["AddressInterpolation.CLI"]),
        .library(
            name: "AddressInterpolation",
            targets: ["AddressInterpolation"]),
        ],
    dependencies: [
        .package(url: "https://github.com/igor-makarov/SwiftPostal.git", .branch("master")),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.11.4"),
        .package(url: "https://github.com/crossroadlabs/Regex.git", from: "1.1.0"),
        ],
    targets: [
        .target(name: "AddressInterpolation",
                dependencies: [
                    "SwiftPostal",
                    "SQLite",
                    "Regex",
                    ]),
        .target(name: "AddressInterpolation.CLI",
                dependencies: [
                    "AddressInterpolation",
                    "Commander"
            ]),
        .target(name: "AddressInterpolation.ProfilerHelper",
                dependencies: [
                    "AddressInterpolation"
            ]),
        .testTarget(name: "AddressInterpolation.Tests",
                    dependencies: [
                        "AddressInterpolation"
            ]),
        ]
)

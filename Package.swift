// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftAddressInterpolation",
    products: [
        .executable(
            name: "Interpolate",
            targets: ["AddressInterpolation.CLI"]),
        .library(
            name: "AddressInterpolation.Framework",
            targets: ["AddressInterpolation"]),
        ],
    dependencies: [
        .package(url: "https://github.com/igor-makarov/SwiftPostal.git", .branch("master")),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "2.9.0"),
        ],
    targets: [
        .target(name: "AddressInterpolation",
                dependencies: [
                    "SwiftPostal",
                    "GRDB",
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

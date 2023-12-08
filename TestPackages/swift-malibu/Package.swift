// swift-tools-version:5.8
import PackageDescription

let package:Package = .init(name: "Swift Malibu",
    products:
    [
        .library(name: "BarbieCore", targets: ["BarbieCore"]),
        .library(name: "BarbieHousing", targets: ["BarbieHousing"]),
        .library(name: "BarbieAddressing", targets: ["BarbieAddressing"]),

        .library(name: "DefaultImplementations", targets: ["DefaultImplementations"]),
    ],
    targets:
    [
        .target(name: "BarbieCore",
            exclude:
            [
                "documentation",
            ]),

        .target(name: "BarbieHousing",
            dependencies:
            [
                .target(name: "BarbieCore"),
                .target(name: "DollhouseSecurity"),
            ]),

        .target(name: "BarbieIdentification",
            dependencies:
            [
                .target(name: "BarbieCore"),
            ]),

        .target(name: "BarbieLegacyIdentification",
            dependencies:
            [
                .target(name: "BarbieCore"),
            ]),

        .target(name: "BarbieAddressing",
            dependencies:
            [
                .target(name: "BarbieHousing"),
            ]),

        .target(name: "DefaultImplementations"),

        .target(name: "DollhouseSecurity"),
    ])

// swift-tools-version:5.8
import PackageDescription

let package:Package = .init(name: "Swift Codelinks (test package)",
    products:
    [
        .library(name: "BarbieCore", targets: ["BarbieCore"]),
        .library(name: "BarbieHousing", targets: ["BarbieHousing"]),
        .library(name: "BarbieAddressing", targets: ["BarbieAddressing"]),
    ],
    targets:
    [
        .target(name: "BarbieCore"),

        .target(name: "BarbieHousing",
            dependencies:
            [
                .target(name: "BarbieCore"),
            ]),

        .target(name: "BarbieAddressing",
            dependencies:
            [
                .target(name: "BarbieHousing"),
            ]),
    ])

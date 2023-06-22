// swift-tools-version:5.8
import PackageDescription

let package:Package = .init(name: "Swift Codelinks (test package)",
    products:
    [
        .library(name: "BarbieCore", targets: ["BarbieCore"]),
        .library(name: "BarbieHousing", targets: ["BarbieHousing"]),
        .library(name: "BarbieAddressing", targets: ["BarbieAddressing"]),
    ],
    dependencies:
    [
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMinor(
            from: "2.54.0")),
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
                .product(name: "NIOCore", package: "swift-nio"),
            ]),

        .target(name: "BarbieAddressing",
            dependencies:
            [
                .target(name: "BarbieHousing"),
            ]),
    ])

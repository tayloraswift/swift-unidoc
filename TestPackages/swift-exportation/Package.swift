// swift-tools-version:5.10
import PackageDescription

let package:Package = .init(name: "Swift Unidoc Exportation Tests",
    products:
    [
        .library(name: "A", targets: ["A"]),
        .library(name: "B", targets: ["B"]),
    ],
    targets:
    [
        .target(name: "_A"),
        .target(name: "A", dependencies: ["_A"]),
        .target(name: "B", dependencies: ["A"]),
    ])

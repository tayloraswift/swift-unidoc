// swift-tools-version:6.0
import PackageDescription

let package:Package = .init(name: "Swift Unidoc Test Modules",
    products:
    [
        .library(name: "A", targets: ["A"]),
        .library(name: "B", targets: ["B"]),
    ],
    targets:
    [
        .target(name: "A"),
        .target(name: "B"),
    ])

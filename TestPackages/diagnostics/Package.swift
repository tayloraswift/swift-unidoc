// swift-tools-version:6.0
import PackageDescription

let package:Package = .init(name: "Swift Unidoc Test Modules",
    products:
    [
        .library(name: "A", targets: ["A"]),
    ],
    targets:
    [
        .target(name: "A"),
    ])

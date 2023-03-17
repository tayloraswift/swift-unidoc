// swift-tools-version:5.7
import PackageDescription

let package:Package = .init(name: "swift-unidoc-testmodules",
    products:
    [
        .library(name: "Extensions", targets: ["Extensions"]),
        .library(name: "GenericExtensions", targets: ["GenericExtensions"]),
        .library(name: "Protocols", targets: ["Protocols"]),
    ],
    targets:
    [
        .target(name: "Extensions"),
        .target(name: "GenericExtensions"),
        .target(name: "Protocols"),
    ])

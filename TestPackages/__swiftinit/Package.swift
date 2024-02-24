// swift-tools-version:5.8
import PackageDescription

let package:Package = .init(name: "Swiftinit",
    products:
    [
        .library(name: "Articles", targets: ["Articles"]),
        .library(name: "Help", targets: ["Help"]),
    ],
    targets:
    [
        .target(name: "Articles"),
        .target(name: "Help"),
    ])

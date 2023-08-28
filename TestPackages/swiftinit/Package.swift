// swift-tools-version:5.8
import PackageDescription

let package:Package = .init(name: "Swiftinit",
    products:
    [
        .library(name: "Articles", targets: ["Articles"]),
    ],
    targets:
    [
        .target(name: "Articles", exclude: ["md"]),
    ])

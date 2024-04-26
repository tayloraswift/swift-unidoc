// swift-tools-version:5.10
import PackageDescription

let package:Package = .init(name: "Swift Unidoc Test Modules",
    products:
    [
        .library(name: "LinkAnchors", targets: ["LinkAnchors"]),
    ],
    targets:
    [
        .target(name: "LinkAnchors"),
    ])

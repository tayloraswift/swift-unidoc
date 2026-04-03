// swift-tools-version:6.0
import PackageDescription

let package: Package = .init(
    name: "Swift Unidoc Test Modules",
    products: [
        .library(name: "DocCOptions", targets: ["DocCOptions"]),
        .library(name: "LinkAnchors", targets: ["LinkAnchors"]),
    ],
    targets: [
        .target(name: "DocCOptions"),
        .target(name: "LinkAnchors"),
    ]
)

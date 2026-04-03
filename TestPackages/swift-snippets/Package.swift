// swift-tools-version:6.0
import PackageDescription

let package: Package = .init(
    name: "Swift Unidoc Snippets Test Package",
    products: [
        .library(name: "Snippets", targets: ["Snippets"]),
    ],
    targets: [
        .target(name: "Snippets", dependencies: []),
    ]
)

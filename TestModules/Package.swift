// swift-tools-version:5.8
import PackageDescription

let package:Package = .init(name: "swift-unidoc-testmodules",
    products:
    [
        .library(name: "ExtendableTypesWithConstraints",
            targets: ["ExtendableTypesWithConstraints"]),
    ],
    targets:
    [
        .target(name: "ExtendableTypesWithConstraints"),
    ])

// swift-tools-version:5.9
import PackageDescription

let package:Package = .init(name: "swift-unidoc-testmodules",
    products:
    [
        .library(name: "ACL",
            targets: ["ACL"]),
        .library(name: "ExtendableTypesWithConstraints",
            targets: ["ExtendableTypesWithConstraints"]),
    ],
    targets:
    [
        .target(name: "ACL"),
        .target(name: "ExtendableTypesWithConstraints"),
    ])

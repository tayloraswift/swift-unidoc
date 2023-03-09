// swift-tools-version:5.7
import PackageDescription

let package:Package = .init(
    name: "swift-unidoc",
    products: 
    [
    ],
    dependencies: 
    [
        .package(url: "https://github.com/kelvin13/swift-json", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/kelvin13/swift-grammar", .upToNextMinor(from: "0.3.1")),
        .package(url: "https://github.com/kelvin13/swift-hash", .upToNextMinor(from: "0.5.0")),
        .package(url: "https://github.com/kelvin13/swift-mongodb", .upToNextMinor(from: "0.1.10")),
        
        .package(url: "https://github.com/apple/swift-system.git", .upToNextMinor(from: "1.1.1")),
    ],
    targets: 
    [
        .target(name: "ZooInheritedTypePrecedence",
            dependencies:
            [
            ], 
            path: "Zoo/InheritedTypePrecedence"),

        .target(name: "ZooInheritedTypes",
            dependencies:
            [
            ], 
            path: "Zoo/InheritedTypes"),

        .target(name: "ZooOverloadedTypealiases",
            dependencies:
            [
            ], 
            path: "Zoo/OverloadedTypealiases"),
    ])

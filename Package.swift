// swift-tools-version:5.7
import PackageDescription

let package:Package = .init(
    name: "swift-unidoc",
    products: 
    [
    ],
    dependencies: 
    [
        //.package(url: "https://github.com/kelvin13/swift-json", .upToNextMinor(from: "0.4.2")),
        .package(path: "../swift-json"),

        .package(url: "https://github.com/kelvin13/swift-grammar", .upToNextMinor(from: "0.3.1")),
        .package(url: "https://github.com/kelvin13/swift-hash", .upToNextMinor(from: "0.5.0")),
        .package(url: "https://github.com/kelvin13/swift-mongodb", .upToNextMinor(from: "0.1.10")),
        
        .package(url: "https://github.com/apple/swift-system.git", .upToNextMinor(from: "1.2.1")),
    ],
    targets: 
    [
        .target(name: "SemanticVersion"),

        .target(name: "Symbols"),

        .target(name: "SymbolGraphs",
            dependencies:
            [
                .target(name: "System"),
                .target(name: "SemanticVersion"),
                .target(name: "Symbols"),
                .product(name: "JSONDecoding", package: "swift-json"),
                .product(name: "JSONEncoding", package: "swift-json"),
            ]),
        
        .target(name: "System",
            dependencies:
            [
                .product(name: "SystemPackage", package: "swift-system"),
            ]),
        
        .executableTarget(name: "SymbolGraphsTests",
            dependencies:
            [
                .target(name: "SymbolGraphs"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SymbolGraphs"),


        .target(name: "ZooDeclarations",
            path: "Zoo/Declarations"),

        .target(name: "ZooInheritedTypePrecedence",
            path: "Zoo/InheritedTypePrecedence"),

        .target(name: "ZooInheritedTypes",
            path: "Zoo/InheritedTypes"),

        .target(name: "ZooOverloadedTypealiases",
            path: "Zoo/OverloadedTypealiases"),

        .target(name: "ZooUnderscoredProtocols",
            path: "Zoo/UnderscoredProtocols"),

        .target(name: "ZooProtocols",
            path: "Zoo/Protocols"),

        .target(name: "ZooProtocolConformers",
            dependencies:
            [
                .target(name: "ZooProtocols"),
            ], 
            path: "Zoo/ProtocolConformers"),
    ])

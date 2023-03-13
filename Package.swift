// swift-tools-version:5.7
import PackageDescription

let package:Package = .init(
    name: "swift-unidoc",
    products: 
    [
        .library(name: "Declarations", targets: ["Declarations"]),
        .library(name: "Generics", targets: ["Generics"]),
        .library(name: "SemanticVersions", targets: ["SemanticVersions"]),
        .library(name: "SymbolAvailability", targets: ["SymbolAvailability"]),
        .library(name: "SymbolResolution", targets: ["SymbolResolution"]),
        .library(name: "Symbols", targets: ["Symbols"]),
        .library(name: "SymbolGraphs", targets: ["SymbolGraphs"]),
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
        .target(name: "Declarations"),

        .target(name: "Generics"),

        .target(name: "SemanticVersions"),

        .target(name: "Symbols"),

        .target(name: "SymbolAvailability",
            dependencies:
            [
                .target(name: "SemanticVersions"),
                .target(name: "Symbols"),
            ]),

        .target(name: "SymbolResolution",
            dependencies:
            [
                .target(name: "Symbols"),

                .product(name: "JSONDecoding", package: "swift-json"),
                .product(name: "JSONEncoding", package: "swift-json"),
            ]),

        .target(name: "SymbolGraphs",
            dependencies:
            [
                .target(name: "Declarations"),
                .target(name: "Generics"),
                .target(name: "System"),
                .target(name: "SymbolAvailability"),
                .target(name: "SymbolResolution"),
            ]),
        
        .target(name: "System",
            dependencies:
            [
                .product(name: "SystemPackage", package: "swift-system"),
            ]),
        
        .executableTarget(name: "SymbolResolutionTests",
            dependencies:
            [
                .target(name: "SymbolResolution"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SymbolResolution"),
        
        .executableTarget(name: "SymbolGraphsTests",
            dependencies:
            [
                .target(name: "SymbolGraphs"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SymbolGraphs",
            swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),


        .target(name: "ZooAvailability",
            path: "Zoo/Availability"),

        .target(name: "ZooConstraints",
            path: "Zoo/Constraints"),

        .target(name: "ZooDeclarations",
            path: "Zoo/Declarations"),

        .target(name: "ZooDoccomments",
            path: "Zoo/Doccomments"),

        .target(name: "ZooExtensions",
            path: "Zoo/Extensions"),

        .target(name: "ZooExtensionsDeep",
            dependencies:
            [
                .target(name: "ZooExtensions"),
            ],
            path: "Zoo/ExtensionsDeep"),

        .target(name: "ZooInheritedTypePrecedence",
            path: "Zoo/InheritedTypePrecedence"),

        .target(name: "ZooInheritedTypes",
            path: "Zoo/InheritedTypes"),

        .target(name: "ZooOverloadedTypealiases",
            path: "Zoo/OverloadedTypealiases"),

        .target(name: "ZooProtocols",
            path: "Zoo/Protocols"),

        .target(name: "ZooProtocolConformers",
            dependencies:
            [
                .target(name: "ZooProtocols"),
            ], 
            path: "Zoo/ProtocolConformers"),

        .target(name: "ZooSPI",
            path: "Zoo/SPI"),

        .target(name: "ZooUnderscoredProtocols",
            path: "Zoo/UnderscoredProtocols"),
    ])

// swift-tools-version:5.7
import PackageDescription

let package:Package = .init(
    name: "swift-unidoc",
    platforms: [.macOS(.v11)],
    products:
    [
        .library(name: "Declarations", targets: ["Declarations"]),
        .library(name: "Generics", targets: ["Generics"]),

        .library(name: "Packages", targets: ["Packages"]),
        .library(name: "PackageManifests", targets: ["PackageManifests"]),
        .library(name: "PackageResolution", targets: ["PackageResolution"]),

        .library(name: "SemanticVersions", targets: ["SemanticVersions"]),

        .library(name: "SymbolAvailability", targets: ["SymbolAvailability"]),
        .library(name: "SymbolGraphCompiler", targets: ["SymbolGraphCompiler"]),
        .library(name: "SymbolGraphs", targets: ["SymbolGraphs"]),
        .library(name: "SymbolNamespaces", targets: ["SymbolNamespaces"]),
        .library(name: "SymbolResolution", targets: ["SymbolResolution"]),
        .library(name: "Symbols", targets: ["Symbols"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/kelvin13/swift-json", .upToNextMinor(from: "0.4.5")),

        .package(url: "https://github.com/kelvin13/swift-grammar", .upToNextMinor(from: "0.3.1")),
        .package(url: "https://github.com/kelvin13/swift-mongodb", .upToNextMinor(from: "0.1.12")),
        
        .package(url: "https://github.com/apple/swift-system.git", .upToNextMinor(from: "1.2.1")),
    ],
    targets:
    [
        .target(name: "Declarations"),

        .target(name: "Generics"),

        .target(name: "Packages", dependencies:
            [
                .target(name: "SemanticVersions"),
                .target(name: "Symbols"),
            ]),

        .target(name: "PackageManifests", dependencies:
            [
                .target(name: "PackageMetadata"),
            ]),

        .target(name: "PackageMetadata", dependencies:
            [
                .target(name: "Packages"),

                .product(name: "JSONDecoding", package: "swift-json"),
                .product(name: "JSONEncoding", package: "swift-json"),
            ]),

        .target(name: "PackageResolution", dependencies:
            [
                .target(name: "PackageMetadata"),
            ]),

        .target(name: "SemanticVersions"),

        .target(name: "Symbols"),

        .target(name: "SymbolAvailability", dependencies:
            [
                .target(name: "SemanticVersions"),
                .target(name: "Symbols"),
            ]),

        .target(name: "SymbolNamespaces", dependencies:
            [
                .target(name: "Declarations"),
                .target(name: "Generics"),
                .target(name: "SymbolAvailability"),
                .target(name: "SymbolResolution"),
            ]),
        
        .target(name: "SymbolResolution", dependencies:
            [
                .target(name: "Symbols"),

                .product(name: "JSONDecoding", package: "swift-json"),
                .product(name: "JSONEncoding", package: "swift-json"),
            ]),

        .target(name: "SymbolGraphs", dependencies:
            [
                .target(name: "Declarations"),
                .target(name: "Generics"),
                .target(name: "SymbolAvailability"),
            ]),
        
        .target(name: "SymbolGraphCompiler", dependencies:
            [
                .target(name: "PackageManifests"),
                .target(name: "PackageResolution"),
                .target(name: "SymbolNamespaces"),
                .target(name: "System"),
            ]),
        
        .target(name: "System", dependencies:
            [
                .product(name: "SystemPackage", package: "swift-system"),
            ]),
        
        .executableTarget(name: "DeclarationsTests", dependencies:
            [
                .target(name: "Declarations"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/Declarations"),
        
        .executableTarget(name: "PackageManifestsTests", dependencies:
            [
                .target(name: "PackageManifests"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/PackageManifests"),

        .executableTarget(name: "PackageResolutionTests", dependencies:
            [
                .target(name: "PackageResolution"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/PackageResolution"),
        
        .executableTarget(name: "SemanticVersionsTests", dependencies:
            [
                .target(name: "SemanticVersions"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SemanticVersions"),
        
        .executableTarget(name: "SymbolResolutionTests", dependencies:
            [
                .target(name: "SymbolResolution"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SymbolResolution"),
        
        .executableTarget(name: "SymbolNamespacesTests", dependencies:
            [
                .target(name: "SymbolNamespaces"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SymbolNamespaces",
            swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
    ])

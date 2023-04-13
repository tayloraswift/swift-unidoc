// swift-tools-version:5.7
import PackageDescription

let package:Package = .init(
    name: "swift-unidoc",
    platforms: [.macOS(.v11)],
    products:
    [
        .library(name: "Codelinks", targets: ["Codelinks"]),
        .library(name: "Declarations", targets: ["Declarations"]),
        .library(name: "Generics", targets: ["Generics"]),

        .library(name: "HTML", targets: ["HTML"]),
        .library(name: "HTMLRendering", targets: ["HTMLRendering"]),

        .library(name: "LexicalPaths", targets: ["LexicalPaths"]),

        .library(name: "MarkdownABI", targets: ["MarkdownABI"]),
        .library(name: "MarkdownParsing", targets: ["MarkdownParsing"]),
        .library(name: "MarkdownRendering", targets: ["MarkdownRendering"]),
        .library(name: "MarkdownSemantics", targets: ["MarkdownSemantics"]),
        .library(name: "MarkdownTrees", targets: ["MarkdownTrees"]),

        .library(name: "Packages", targets: ["Packages"]),
        .library(name: "PackageManifests", targets: ["PackageManifests"]),
        .library(name: "PackageResolution", targets: ["PackageResolution"]),

        .library(name: "SemanticVersions", targets: ["SemanticVersions"]),

        .library(name: "SymbolAvailability", targets: ["SymbolAvailability"]),
        .library(name: "SymbolGraphCompiler", targets: ["SymbolGraphCompiler"]),
        .library(name: "SymbolGraphs", targets: ["SymbolGraphs"]),
        .library(name: "SymbolColonies", targets: ["SymbolColonies"]),
        .library(name: "SymbolResolution", targets: ["SymbolResolution"]),
        .library(name: "Symbols", targets: ["Symbols"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/tayloraswift/swift-json", .upToNextMinor(
            from: "0.5.0")),
        .package(url: "https://github.com/tayloraswift/swift-grammar", .upToNextMinor(
            from: "0.3.2")),
        .package(url: "https://github.com/tayloraswift/swift-mongodb", .upToNextMinor(
            from: "0.1.13")),
        
        .package(url: "https://github.com/SDGGiesbrecht/swift-markdown", .upToNextMinor(
            from: "0.50700.0")),

        .package(url: "https://github.com/apple/swift-system.git", .upToNextMinor(
            from: "1.2.1")),
    ],
    targets:
    [
        .target(name: "Codelinks", dependencies:
            [
                .target(name: "LexicalPaths"),
            ]),
        
        .target(name: "Declarations"),

        .target(name: "Generics"),

        .target(name: "HTML"),

        .target(name: "HTMLRendering", dependencies:
            [
                .target(name: "HTML"),
            ]),
        
        .target(name: "LexicalPaths"),

        .target(name: "MarkdownABI"),

        .target(name: "MarkdownRendering", dependencies:
            [
                .target(name: "HTMLRendering"),
                .target(name: "MarkdownABI"),
            ]),

        .target(name: "MarkdownTrees", dependencies:
            [
                .target(name: "MarkdownABI")
            ]),

        .target(name: "MarkdownParsing", dependencies:
            [
                .target(name: "MarkdownTrees"),
                //  TODO: this links Foundation. Need to find a replacement.
                .product(name: "Markdown", package: "swift-markdown"),
            ]),

        .target(name: "MarkdownSemantics", dependencies:
            [
                .target(name: "Codelinks"),
                .target(name: "MarkdownTrees"),
            ]),

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
            ]),

        .target(name: "SymbolColonies", dependencies:
            [
                .target(name: "Declarations"),
                .target(name: "Generics"),
                .target(name: "LexicalPaths"),
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
                .target(name: "Packages"),
                .target(name: "SymbolAvailability"),
                .target(name: "Symbols"),
            ]),
        
        .target(name: "SymbolGraphCompiler", dependencies:
            [
                .target(name: "PackageManifests"),
                .target(name: "PackageResolution"),
                .target(name: "SymbolColonies"),
                .target(name: "System"),

                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),
        
        .target(name: "System", dependencies:
            [
                .product(name: "SystemPackage", package: "swift-system"),
            ]),
        
        
        .executableTarget(name: "CodelinksTests", dependencies:
            [
                .target(name: "Codelinks"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/Codelinks"),
        
        .executableTarget(name: "DeclarationsTests", dependencies:
            [
                .target(name: "Declarations"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/Declarations"),
        
        .executableTarget(name: "MarkdownParsingTests", dependencies:
            [
                .target(name: "MarkdownParsing"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/MarkdownParsing"),
        
        .executableTarget(name: "MarkdownRenderingTests", dependencies:
            [
                .target(name: "MarkdownRendering"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/MarkdownRendering"),
        
        .executableTarget(name: "MarkdownSemanticsTests", dependencies:
            [
                .target(name: "MarkdownParsing"),
                .target(name: "MarkdownRendering"),
                .target(name: "MarkdownSemantics"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/MarkdownSemantics"),
        
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
        
        .executableTarget(name: "SymbolColoniesTests", dependencies:
            [
                .target(name: "SymbolColonies"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SymbolColonies",
            swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
        
        .executableTarget(name: "SymbolGraphCompilerTests", dependencies:
            [
                .target(name: "SymbolGraphCompiler"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SymbolGraphCompiler",
            swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
    ])

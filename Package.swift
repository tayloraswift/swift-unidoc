// swift-tools-version:5.7
import PackageDescription

let package:Package = .init(
    name: "swift-unidoc",
    platforms: [.macOS(.v11)],
    products:
    [
        .library(name: "Availability", targets: ["Availability"]),
        .library(name: "AvailabilityDomain", targets: ["AvailabilityDomain"]),
        .library(name: "Codelinks", targets: ["Codelinks"]),
        .library(name: "CodelinkResolution", targets: ["CodelinkResolution"]),
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

        .library(name: "PackageMetadata", targets: ["PackageMetadata"]),
        .library(name: "Repositories", targets: ["Repositories"]),

        .library(name: "SemanticVersions", targets: ["SemanticVersions"]),

        .library(name: "Symbols", targets: ["Symbols"]),
        .library(name: "SymbolGraphParts", targets: ["SymbolGraphParts"]),
        .library(name: "SymbolGraphCompiler", targets: ["SymbolGraphCompiler"]),
        .library(name: "SymbolGraphDriver", targets: ["SymbolGraphDriver"]),
        .library(name: "SymbolGraphLinker", targets: ["SymbolGraphLinker"]),
        .library(name: "SymbolGraphs", targets: ["SymbolGraphs"]),
    ],
    dependencies:
    [
        .package(url: "https://github.com/tayloraswift/swift-json", .upToNextMinor(
            from: "0.5.1")),
        .package(url: "https://github.com/tayloraswift/swift-grammar", .upToNextMinor(
            from: "0.3.2")),
        .package(url: "https://github.com/tayloraswift/swift-mongodb", .upToNextMinor(
           from: "0.1.16")),

        .package(url: "https://github.com/SDGGiesbrecht/swift-markdown", .upToNextMinor(
            from: "0.50800.0")),

        .package(url: "https://github.com/apple/swift-syntax", exact: "508.0.0"),

        .package(url: "https://github.com/apple/swift-system.git", .upToNextMinor(
            from: "1.2.1")),
    ],
    targets:
    [
        .target(name: "AvailabilityDomain"),

        .target(name: "Availability", dependencies:
            [
                .target(name: "AvailabilityDomain"),
                .target(name: "SemanticVersions"),
            ]),

        .target(name: "Codelinks", dependencies:
            [
                .target(name: "LexicalPaths"),
            ]),

        .target(name: "CodelinkResolution", dependencies:
            [
                .target(name: "Codelinks"),
                .target(name: "SymbolGraphs"),
            ]),

        .target(name: "Declarations", dependencies:
            [
                .target(name: "Availability"),
                .target(name: "Generics"),
                .target(name: "MarkdownABI")
            ]),

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

        .target(name: "Repositories", dependencies:
            [
                .target(name: "SemanticVersions"),
                .target(name: "StringIdentifiers"),
            ]),

        .target(name: "PackageMetadata", dependencies:
            [
                .target(name: "Repositories"),

                .product(name: "JSONDecoding", package: "swift-json"),
                .product(name: "JSONEncoding", package: "swift-json"),
            ]),

        .target(name: "SemanticVersions"),

        .target(name: "StringIdentifiers"),

        .target(name: "Symbols"),

        .target(name: "SymbolGraphParts", dependencies:
            [
                .target(name: "Declarations"),
                .target(name: "LexicalPaths"),
                .target(name: "Repositories"),
                .target(name: "Symbols"),
                .product(name: "JSONDecoding", package: "swift-json"),
                .product(name: "JSONEncoding", package: "swift-json"),
            ]),

        .target(name: "SymbolGraphs", dependencies:
            [
                .target(name: "Codelinks"),
                .target(name: "Declarations"),
                .target(name: "LexicalPaths"),
                .target(name: "Repositories"),
                .target(name: "Symbols"),

                .product(name: "BSONDecoding", package: "swift-mongodb"),
                .product(name: "BSONEncoding", package: "swift-mongodb"),
            ]),

        .target(name: "SymbolGraphCompiler", dependencies:
            [
                .target(name: "SymbolGraphs"),
                .target(name: "SymbolGraphParts"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),

        .target(name: "SymbolGraphDriver", dependencies:
            [
                .target(name: "PackageMetadata"),
                .target(name: "SymbolGraphCompiler"),
                .target(name: "SymbolGraphLinker"),
                .target(name: "System"),
            ]),

        .target(name: "SymbolGraphLinker", dependencies:
            [
                .target(name: "CodelinkResolution"),
                .target(name: "MarkdownParsing"),
                .target(name: "MarkdownSemantics"),
                .target(name: "PackageMetadata"),
                .target(name: "SymbolGraphCompiler"),
            ]),

        .target(name: "System", dependencies:
            [
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),


        .executableTarget(name: "Unidoc",
            dependencies:
            [
                .target(name: "SymbolGraphDriver"),
            ]),


        .executableTarget(name: "CodelinksTests", dependencies:
            [
                .target(name: "Codelinks"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/Codelinks"),

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

        .executableTarget(name: "PackageMetadataTests", dependencies:
            [
                .target(name: "PackageMetadata"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/PackageMetadata"),

        .executableTarget(name: "SemanticVersionsTests", dependencies:
            [
                .target(name: "SemanticVersions"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SemanticVersions"),

        .executableTarget(name: "SymbolsTests", dependencies:
            [
                .target(name: "Symbols"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/Symbols"),

        .executableTarget(name: "SymbolGraphsTests", dependencies:
            [
                .target(name: "SymbolGraphs"),
                //.target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SymbolGraphs"),

        .executableTarget(name: "SymbolGraphPartsTests", dependencies:
            [
                .target(name: "SymbolGraphParts"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SymbolGraphParts"),

        .executableTarget(name: "SymbolGraphCompilerTests", dependencies:
            [
                .target(name: "SymbolGraphCompiler"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SymbolGraphCompiler"),

        .executableTarget(name: "SymbolGraphDriverTests", dependencies:
            [
                .target(name: "SymbolGraphDriver"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SymbolGraphDriver",
            swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
    ])

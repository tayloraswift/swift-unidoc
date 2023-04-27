// swift-tools-version:5.7
import PackageDescription

let package:Package = .init(
    name: "swift-unidoc",
    platforms: [.macOS(.v11)],
    products:
    [
        .library(name: "Availability", targets: ["Availability"]),
        .library(name: "Codelinks", targets: ["Codelinks"]),
        .library(name: "CodelinkResolution", targets: ["CodelinkResolution"]),
        .library(name: "Declarations", targets: ["Declarations"]),
        .library(name: "Fragments", targets: ["Fragments"]),
        .library(name: "Generics", targets: ["Generics"]),

        .library(name: "HTML", targets: ["HTML"]),
        .library(name: "HTMLRendering", targets: ["HTMLRendering"]),

        .library(name: "LexicalPaths", targets: ["LexicalPaths"]),

        .library(name: "MarkdownABI", targets: ["MarkdownABI"]),
        .library(name: "MarkdownParsing", targets: ["MarkdownParsing"]),
        .library(name: "MarkdownRendering", targets: ["MarkdownRendering"]),
        .library(name: "MarkdownSemantics", targets: ["MarkdownSemantics"]),
        .library(name: "MarkdownTrees", targets: ["MarkdownTrees"]),

        .library(name: "Repositories", targets: ["Repositories"]),
        .library(name: "PackageDescriptions", targets: ["PackageDescriptions"]),

        .library(name: "SemanticVersions", targets: ["SemanticVersions"]),

        .library(name: "Symbolics", targets: ["Symbolics"]),
        .library(name: "Symbols", targets: ["Symbols"]),
        .library(name: "SymbolGraphParts", targets: ["SymbolGraphParts"]),
        .library(name: "SymbolGraphCompiler", targets: ["SymbolGraphCompiler"]),
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
            from: "0.1.13")),
        
        .package(url: "https://github.com/SDGGiesbrecht/swift-markdown", .upToNextMinor(
            from: "0.50800.0")),

        .package(url: "https://github.com/apple/swift-system.git", .upToNextMinor(
            from: "1.2.1")),
    ],
    targets:
    [
        .target(name: "Availability", dependencies:
            [
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
                .target(name: "Fragments"),
                .target(name: "Generics"),
            ]),
        
        .target(name: "Fragments"),

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

        .target(name: "PackageDescriptions", dependencies:
            [
                .target(name: "Repositories"),

                .product(name: "JSONDecoding", package: "swift-json"),
                .product(name: "JSONEncoding", package: "swift-json"),
            ]),

        .target(name: "SemanticVersions"),

        .target(name: "SourceMaps", dependencies:
            [
                .target(name: "StringIdentifiers"),
            ]),

        .target(name: "StringIdentifiers"),

        .target(name: "Symbolics"),

        .target(name: "Symbols", dependencies:
            [
                .target(name: "Symbolics"),
            ]),

        .target(name: "SymbolGraphParts", dependencies:
            [
                .target(name: "Declarations"),
                .target(name: "LexicalPaths"),
                .target(name: "Repositories"),
                .target(name: "SourceMaps"),
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
                .target(name: "SourceMaps"),
                .target(name: "Symbolics"),
            ]),

        .target(name: "SymbolGraphCompiler", dependencies:
            [
                .target(name: "SymbolGraphParts"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),
        
        .target(name: "SymbolGraphLinker", dependencies:
            [
                .target(name: "CodelinkResolution"),
                .target(name: "MarkdownParsing"),
                .target(name: "MarkdownSemantics"),
                .target(name: "PackageDescriptions"),
                .target(name: "SymbolGraphCompiler"),
                .target(name: "System"),
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
        
        .executableTarget(name: "FragmentsTests", dependencies:
            [
                .target(name: "Fragments"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/Fragments"),
        
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
        
        .executableTarget(name: "PackageDescriptionsTests", dependencies:
            [
                .target(name: "PackageDescriptions"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/PackageDescriptions"),
        
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
        
        .executableTarget(name: "SymbolGraphPartsTests", dependencies:
            [
                .target(name: "SymbolGraphParts"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SymbolGraphParts",
            swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
        
        .executableTarget(name: "SymbolGraphCompilerTests", dependencies:
            [
                .target(name: "SymbolGraphCompiler"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            path: "Tests/SymbolGraphCompiler",
            swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
    ])

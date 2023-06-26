// swift-tools-version:5.8
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
        .library(name: "Doclinks", targets: ["Doclinks"]),
        .library(name: "FNV1", targets: ["FNV1"]),
        .library(name: "Generics", targets: ["Generics"]),

        .library(name: "HTML", targets: ["HTML"]),
        .library(name: "HTMLRendering", targets: ["HTMLRendering"]),

        .library(name: "HTTPServer", targets: ["HTTPServer"]),

        .library(name: "LexicalPaths", targets: ["LexicalPaths"]),

        .library(name: "MarkdownABI", targets: ["MarkdownABI"]),
        .library(name: "MarkdownParsing", targets: ["MarkdownParsing"]),
        .library(name: "MarkdownRendering", targets: ["MarkdownRendering"]),
        .library(name: "MarkdownSemantics", targets: ["MarkdownSemantics"]),
        .library(name: "MarkdownTrees", targets: ["MarkdownTrees"]),

        .library(name: "Media", targets: ["Media"]),

        .library(name: "ModuleGraphs", targets: ["ModuleGraphs"]),

        .library(name: "Multiparts", targets: ["Multiparts"]),

        .library(name: "PackageGraphs", targets: ["PackageGraphs"]),
        .library(name: "PackageMetadata", targets: ["PackageMetadata"]),

        .library(name: "SemanticVersions", targets: ["SemanticVersions"]),
        .library(name: "Sources", targets: ["Sources"]),

        .library(name: "SymbolGraphParts", targets: ["SymbolGraphParts"]),
        .library(name: "SymbolGraphs", targets: ["SymbolGraphs"]),
        .library(name: "Symbols", targets: ["Symbols"]),

        .library(name: "System", targets: ["System"]),

        .library(name: "Unidoc", targets: ["Unidoc"]),
        .library(name: "UnidocCompiler", targets: ["UnidocCompiler"]),
        .library(name: "UnidocDatabase", targets: ["UnidocDatabase"]),
        .library(name: "UnidocDiagnostics", targets: ["UnidocDiagnostics"]),
        .library(name: "UnidocDriver", targets: ["UnidocDriver"]),
        .library(name: "UnidocLinker", targets: ["UnidocLinker"]),
        .library(name: "UnidocRouting", targets: ["UnidocRouting"]),
    ],
    dependencies:
    [
        .package(url: "https://github.com/tayloraswift/swift-json", .upToNextMinor(
            from: "0.5.1")),
        .package(url: "https://github.com/tayloraswift/swift-grammar", .upToNextMinor(
            from: "0.3.2")),
        .package(url: "https://github.com/tayloraswift/swift-mongodb", .upToNextMinor(
            from: "0.2.3")),

        .package(url: "https://github.com/apple/swift-nio", .upToNextMinor(
            from: "2.54.0")),
        .package(url: "https://github.com/apple/swift-nio-ssl", .upToNextMinor(
            from: "2.24.0")),
        .package(url: "https://github.com/apple/swift-markdown", .upToNextMinor(
            from: "0.2.0")),
        .package(url: "https://github.com/apple/swift-system", .upToNextMinor(
            from: "1.2.1")),
        .package(url: "https://github.com/apple/swift-syntax",
            exact: "508.0.0"),
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
                .target(name: "FNV1"),
                .target(name: "LexicalPaths"),
            ]),

        .target(name: "CodelinkResolution", dependencies:
            [
                .target(name: "Codelinks"),
                .target(name: "ModuleGraphs"),
                .target(name: "Unidoc"),
            ]),

        .target(name: "Declarations", dependencies:
            [
                .target(name: "Availability"),
                .target(name: "Generics"),
                .target(name: "MarkdownABI")
            ]),

        .target(name: "Doclinks", dependencies:
            [
                .target(name: "URI"),
            ]),

        .target(name: "DoclinkResolution", dependencies:
            [
                .target(name: "Doclinks"),
            ]),

        .target(name: "FNV1"),

        .target(name: "Generics"),

        .target(name: "HTML"),

        .target(name: "HTMLRendering", dependencies:
            [
                .target(name: "HTML"),
            ]),

        .target(name: "HTTPServer",
            dependencies:
            [
                .target(name: "Media"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
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
                .target(name: "MarkdownABI"),
                .target(name: "Sources"),
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

        .target(name: "Media"),

        .target(name: "ModuleGraphs", dependencies:
            [
                .target(name: "SemanticVersions"),
            ]),

        .target(name: "Multiparts", dependencies:
            [
                .target(name: "Media"),
                .product(name: "Grammar", package: "swift-grammar"),
            ]),

        .target(name: "PackageGraphs", dependencies:
            [
                .target(name: "ModuleGraphs"),
            ]),

        .target(name: "PackageMetadata", dependencies:
            [
                .target(name: "PackageGraphs"),

                .product(name: "JSONDecoding", package: "swift-json"),
                .product(name: "JSONEncoding", package: "swift-json"),
            ]),

        .target(name: "SemanticVersions"),

        .target(name: "Sources"),

        .target(name: "Symbols", dependencies:
            [
                .target(name: "Sources"),
            ]),

        .target(name: "SymbolGraphParts", dependencies:
            [
                .target(name: "Declarations"),
                .target(name: "LexicalPaths"),
                .target(name: "ModuleGraphs"),
                .target(name: "Symbols"),
                .target(name: "Unidoc"),
                .product(name: "JSONDecoding", package: "swift-json"),
                .product(name: "JSONEncoding", package: "swift-json"),
            ]),

        .target(name: "SymbolGraphs", dependencies:
            [
                .target(name: "Declarations"),
                .target(name: "LexicalPaths"),
                .target(name: "ModuleGraphs"),
                .target(name: "Symbols"),
                .target(name: "Unidoc"),

                .product(name: "BSONDecoding", package: "swift-mongodb"),
                .product(name: "BSONEncoding", package: "swift-mongodb"),
            ]),

        .target(name: "Unidoc", dependencies:
            [
                .target(name: "UnidocPlanes"),
            ]),

        .target(name: "UnidocCompiler", dependencies:
            [
                .target(name: "Symbols"),
                .target(name: "SymbolGraphParts"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),

        .target(name: "UnidocDatabase",
            dependencies:
            [
                .target(name: "SymbolGraphs"),
                .target(name: "UnidocDiagnostics"),
                .product(name: "MongoDB", package: "swift-mongodb"),
            ]),

        .target(name: "UnidocDiagnostics", dependencies:
            [
                .target(name: "CodelinkResolution"),
            ]),

        .target(name: "UnidocDriver", dependencies:
            [
                .target(name: "PackageMetadata"),
                .target(name: "System"),
                .target(name: "UnidocCompiler"),
                .target(name: "UnidocLinker"),
            ]),

        .target(name: "UnidocLinker", dependencies:
            [
                .target(name: "CodelinkResolution"),
                .target(name: "DoclinkResolution"),
                .target(name: "MarkdownParsing"),
                .target(name: "MarkdownSemantics"),
                .target(name: "PackageMetadata"),
                .target(name: "SymbolGraphs"),
                .target(name: "UnidocCompiler"),
                .target(name: "UnidocDiagnostics"),
                .target(name: "UnidocRouting"),
            ]),

        .target(name: "UnidocPlanes"),

        .target(name: "UnidocRouting", dependencies:
            [
                .target(name: "LexicalPaths"),
                .target(name: "ModuleGraphs"),
                .target(name: "Symbols"),
                .target(name: "URI"),
            ]),

        .target(name: "URI", dependencies:
            [
                .product(name: "Grammar", package: "swift-grammar"),
            ]),

        .target(name: "System", dependencies:
            [
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),


        .executableTarget(name: "UnidocServer",
            dependencies:
            [
                .target(name: "HTTPServer"),
                .target(name: "Multiparts"),
                .target(name: "SymbolGraphs"),
                .product(name: "MongoDB", package: "swift-mongodb"),
            ]),

        .executableTarget(name: "CodelinkTests", dependencies:
            [
                .target(name: "Codelinks"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "DoclinkTests", dependencies:
            [
                .target(name: "Doclinks"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "MarkdownParsingTests", dependencies:
            [
                .target(name: "MarkdownParsing"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "MarkdownRenderingTests", dependencies:
            [
                .target(name: "MarkdownRendering"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "MarkdownSemanticsTests", dependencies:
            [
                .target(name: "MarkdownParsing"),
                .target(name: "MarkdownRendering"),
                .target(name: "MarkdownSemantics"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "PackageMetadataTests", dependencies:
            [
                .target(name: "PackageMetadata"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SemanticVersionTests", dependencies:
            [
                .target(name: "SemanticVersions"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SymbolTests", dependencies:
            [
                .target(name: "Symbols"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SymbolGraphTests", dependencies:
            [
                .target(name: "SymbolGraphs"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SymbolGraphPartTests", dependencies:
            [
                .target(name: "SymbolGraphParts"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SystemTests", dependencies:
            [
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            exclude:
            [
                "directories",
            ]),

        .executableTarget(name: "UnidocCompilerTests", dependencies:
            [
                .target(name: "UnidocCompiler"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "UnidocDatabaseTests", dependencies:
            [
                .target(name: "UnidocDatabase"),
                .target(name: "UnidocDriver"),
                .product(name: "MongoTesting", package: "swift-mongodb"),
            ]),

        .executableTarget(name: "UnidocDriverTests", dependencies:
            [
                .target(name: "UnidocDriver"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "URITests", dependencies:
            [
                .target(name: "URI"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),
    ])

for target:PackageDescription.Target in package.targets
{
    {
        var settings:[PackageDescription.SwiftSetting] = $0 ?? []

        settings.append(.enableUpcomingFeature("BareSlashRegexLiterals"))
        settings.append(.enableUpcomingFeature("ConciseMagicFile"))
        settings.append(.enableUpcomingFeature("ExistentialAny"))
        settings.append(.enableUpcomingFeature("StrictConcurrency"))

        settings.append(.define("DEBUG", .when(configuration: .debug)))

        $0 = settings
    } (&target.swiftSettings)
}

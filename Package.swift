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
        .library(name: "Doclinks", targets: ["Doclinks"]),
        .library(name: "DoclinkResolution", targets: ["DoclinkResolution"]),
        .library(name: "FNV1", targets: ["FNV1"]),

        .library(name: "GitHubIntegration", targets: ["GitHubIntegration"]),

        .library(name: "HTML", targets: ["HTML"]),

        .library(name: "HTTPClient", targets: ["HTTPClient"]),
        .library(name: "HTTPServer", targets: ["HTTPServer"]),

        .library(name: "LexicalPaths", targets: ["LexicalPaths"]),

        .library(name: "MarkdownABI", targets: ["MarkdownABI"]),
        .library(name: "MarkdownParsing", targets: ["MarkdownParsing"]),
        .library(name: "MarkdownRendering", targets: ["MarkdownRendering"]),
        .library(name: "MarkdownSemantics", targets: ["MarkdownSemantics"]),
        .library(name: "MarkdownAST", targets: ["MarkdownAST"]),

        .library(name: "Media", targets: ["Media"]),

        .library(name: "MD5", targets: ["MD5"]),

        .library(name: "ModuleGraphs", targets: ["ModuleGraphs"]),

        .library(name: "Multiparts", targets: ["Multiparts"]),

        .library(name: "PackageGraphs", targets: ["PackageGraphs"]),
        .library(name: "PackageMetadata", targets: ["PackageMetadata"]),

        .library(name: "SemanticVersions", targets: ["SemanticVersions"]),
        .library(name: "Signatures", targets: ["Signatures"]),
        .library(name: "Sources", targets: ["Sources"]),

        .library(name: "SymbolGraphBuilder", targets: ["SymbolGraphBuilder"]),
        .library(name: "SymbolGraphCompiler", targets: ["SymbolGraphCompiler"]),
        .library(name: "SymbolGraphLinker", targets: ["SymbolGraphLinker"]),
        .library(name: "SymbolGraphParts", targets: ["SymbolGraphParts"]),
        .library(name: "SymbolGraphs", targets: ["SymbolGraphs"]),
        .library(name: "Symbols", targets: ["Symbols"]),

        .library(name: "System", targets: ["System"]),

        .library(name: "Unidoc", targets: ["Unidoc"]),
        .library(name: "UnidocAnalysis", targets: ["UnidocAnalysis"]),
        .library(name: "UnidocDatabase", targets: ["UnidocDatabase"]),
        .library(name: "UnidocDiagnostics", targets: ["UnidocDiagnostics"]),
        .library(name: "UnidocLinker", targets: ["UnidocLinker"]),
        .library(name: "UnidocPages", targets: ["UnidocPages"]),
        .library(name: "UnidocQueries", targets: ["UnidocQueries"]),
        .library(name: "UnidocRecords", targets: ["UnidocRecords"]),
        .library(name: "UnidocSelectors", targets: ["UnidocSelectors"]),
        .library(name: "URI", targets: ["URI"]),

        .executable(name: "UnidocServer", targets: ["UnidocServer"]),
    ],
    dependencies:
    [
        //.package(url: "https://github.com/tayloraswift/swift-json", .upToNextMinor(
        //    from: "0.6.0")),
        .package(url: "https://github.com/tayloraswift/swift-grammar", .upToNextMinor(
            from: "0.3.2")),
        .package(url: "https://github.com/tayloraswift/swift-mongodb", .upToNextMinor(
            from: "0.8.0")),

        .package(url: "https://github.com/swift-server/swift-backtrace", .upToNextMinor(
            from: "1.3.4")),
        .package(url: "https://github.com/apple/swift-nio", .upToNextMinor(
            from: "2.57.0")),
        .package(url: "https://github.com/apple/swift-nio-http2", .upToNextMinor(
            from: "1.27.0")),
        .package(url: "https://github.com/apple/swift-nio-ssl", .upToNextMinor(
            from: "2.24.0")),
        .package(url: "https://github.com/apple/swift-markdown", .upToNextMinor(
            from: "0.2.0")),
        .package(url: "https://github.com/apple/swift-system", .upToNextMinor(
            from: "1.2.1")),
        .package(url: "https://github.com/apple/swift-syntax",
            exact: "508.0.1"),
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

        .target(name: "Doclinks", dependencies:
            [
                .target(name: "URI"),
            ]),

        .target(name: "DoclinkResolution", dependencies:
            [
                .target(name: "Doclinks"),
            ]),

        .target(name: "FNV1"),

        .target(name: "GitHubClient", dependencies:
            [
                .target(name: "GitHubIntegration"),
                .target(name: "HTTPClient"),
            ]),

        .target(name: "GitHubIntegration", dependencies:
            [
                .target(name: "JSON"),
            ]),

        .target(name: "HTML", dependencies:
            [
                .target(name: "HTMLDOM"),
                .target(name: "HTMLStreaming"),
            ]),

        .target(name: "HTMLDOM"),

        .target(name: "HTMLStreaming", dependencies:
            [
                .target(name: "HTMLDOM"),
            ]),

        .target(name: "HTTP", dependencies:
            [
                .target(name: "Media"),
                .target(name: "MD5"),

                .product(name: "NIOCore", package: "swift-nio"),
            ]),

        .target(name: "HTTPClient", dependencies:
            [
                .target(name: "HTML"),
                .target(name: "Media"),
                .target(name: "MD5"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOHTTP2", package: "swift-nio-http2"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),

        .target(name: "HTTPServer", dependencies:
            [
                .target(name: "HTML"),
                .target(name: "HTTP"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),

        .target(name: "InlineBuffer"),


        .target(name: "JSONAST"),

        .target(name: "JSONDecoding", dependencies:
            [
                .target(name: "JSONAST"),
            ]),

        .target(name: "JSONEncoding", dependencies:
            [
                .target(name: "JSONAST"),
            ]),

        .target(name: "JSONLegacy", dependencies:
            [
                .target(name: "JSONDecoding"),
            ]),

        .target(name: "JSONParsing", dependencies:
            [
                .target(name: "JSONAST"),
                .product(name: "Grammar", package: "swift-grammar"),
            ]),

        .target(name: "JSON", dependencies:
            [
                .target(name: "JSONDecoding"),
                .target(name: "JSONEncoding"),
                .target(name: "JSONParsing"),
            ]),

        .target(name: "LexicalPaths"),

        .target(name: "MarkdownABI"),

        .target(name: "MarkdownRendering", dependencies:
            [
                .target(name: "HTML"),
                .target(name: "MarkdownABI"),
            ]),

        .target(name: "MarkdownAST", dependencies:
            [
                .target(name: "MarkdownABI"),
                .target(name: "Sources"),
            ]),

        .target(name: "MarkdownParsing", dependencies:
            [
                .target(name: "MarkdownAST"),
                //  TODO: this links Foundation. Need to find a replacement.
                .product(name: "Markdown", package: "swift-markdown"),
            ]),

        .target(name: "MarkdownPluginSwift", dependencies:
            [
                .target(name: "MarkdownABI"),
                .product(name: "IDEUtils", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ]),

        .target(name: "MarkdownSemantics", dependencies:
            [
                .target(name: "Codelinks"),
                .target(name: "MarkdownAST"),
            ]),

        .target(name: "MD5", dependencies:
            [
                .target(name: "InlineBuffer"),
            ]),

        .target(name: "Media"),

        .target(name: "ModuleGraphs", dependencies:
            [
                .target(name: "SemanticVersions"),
                .target(name: "SHA1"),
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
                .target(name: "JSON"),
                .target(name: "PackageGraphs"),
            ]),

        .target(name: "SemanticVersions"),

        .target(name: "SHA1", dependencies:
            [
                .target(name: "InlineBuffer"),
            ]),

        .target(name: "Signatures", dependencies:
            [
                .target(name: "Availability"),
                .target(name: "MarkdownABI")
            ]),

        .target(name: "Sources"),

        .target(name: "Symbols", dependencies:
            [
                .target(name: "Sources"),
            ]),

        .target(name: "SymbolGraphBuilder", dependencies:
            [
                .target(name: "MarkdownPluginSwift"),
                .target(name: "PackageMetadata"),
                .target(name: "SymbolGraphCompiler"),
                .target(name: "SymbolGraphLinker"),
                .target(name: "System"),
            ]),

        .target(name: "SymbolGraphCompiler", dependencies:
            [
                .target(name: "SymbolGraphParts"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),

        .target(name: "SymbolGraphLinker", dependencies:
            [
                .target(name: "CodelinkResolution"),
                .target(name: "DoclinkResolution"),
                .target(name: "MarkdownParsing"),
                .target(name: "MarkdownSemantics"),
                .target(name: "ModuleGraphs"),
                .target(name: "PackageMetadata"),
                .target(name: "SymbolGraphCompiler"),
                .target(name: "SymbolGraphs"),
                .target(name: "Symbols"),
                .target(name: "UnidocDiagnostics"),
                .target(name: "URI"),
            ]),

        .target(name: "SymbolGraphParts", dependencies:
            [
                .target(name: "JSON"),
                .target(name: "LexicalPaths"),
                .target(name: "ModuleGraphs"),
                .target(name: "Signatures"),
                .target(name: "Symbols"),
                .target(name: "Unidoc"),
            ]),

        .target(name: "SymbolGraphs", dependencies:
            [
                .target(name: "LexicalPaths"),
                .target(name: "ModuleGraphs"),
                .target(name: "Signatures"),
                .target(name: "Symbols"),
                .target(name: "Unidoc"),

                .product(name: "BSONDecoding", package: "swift-mongodb"),
                .product(name: "BSONEncoding", package: "swift-mongodb"),
            ],
            exclude:
            [
                "README.md",
            ]),

        .target(name: "SymbolGraphTesting", dependencies:
            [
                .target(name: "SymbolGraphs"),
                .target(name: "System"),

                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .target(name: "Unidoc", dependencies:
            [
                .target(name: "UnidocPlanes"),
            ]),

        .target(name: "UnidocAnalysis", dependencies:
            [
                .target(name: "JSONEncoding"),
                .target(name: "MD5"),
                .target(name: "UnidocSelectors"),
            ]),

        .target(name: "UnidocDatabase", dependencies:
            [
                .target(name: "GitHubIntegration"),
                .target(name: "UnidocAnalysis"),
                .target(name: "UnidocLinker"),
                .product(name: "MongoDB", package: "swift-mongodb"),
            ]),

        .target(name: "UnidocDiagnostics", dependencies:
            [
                .target(name: "CodelinkResolution"),
                .target(name: "Signatures"),
            ]),

        .target(name: "UnidocLinker", dependencies:
            [
                .target(name: "CodelinkResolution"),
                .target(name: "DoclinkResolution"),
                .target(name: "UnidocDiagnostics"),
                .target(name: "UnidocRecords"),
            ]),

        .target(name: "UnidocPages", dependencies:
            [
                .target(name: "GitHubIntegration"),
                .target(name: "HTTP"),
                .target(name: "MarkdownRendering"),
                .target(name: "UnidocQueries"),
                .target(name: "URI"),
            ]),

        .target(name: "UnidocPlanes"),

        .target(name: "UnidocQueries", dependencies:
            [
                .target(name: "UnidocDatabase"),
                .target(name: "UnidocSelectors"),
            ]),

        .target(name: "UnidocRecords", dependencies:
            [
                .target(name: "FNV1"),
                .target(name: "SymbolGraphs"),
            ]),

        .target(name: "UnidocSelectors", dependencies:
            [
                .target(name: "UnidocRecords"),
                .target(name: "URI"),
            ]),

        .target(name: "UnixTime", dependencies:
            [
                .product(name: "BSON", package: "swift-mongodb"),
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


        .executableTarget(name: "Massbuild", dependencies:
            [
                .target(name: "SymbolGraphBuilder"),
            ]),

        .executableTarget(name: "UnidocServer", dependencies:
            [
                .target(name: "GitHubClient"),
                .target(name: "HTTPServer"),
                .target(name: "Multiparts"),
                .target(name: "System"),
                .target(name: "UnidocPages"),

                .product(name: "Backtrace", package: "swift-backtrace"),
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

        .executableTarget(name: "FNV1Tests", dependencies:
            [
                .target(name: "FNV1"),
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

        .executableTarget(name: "MD5Tests", dependencies:
            [
                .target(name: "MD5"),
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

        .executableTarget(name: "SymbolGraphBuilderTests", dependencies:
            [
                .target(name: "SymbolGraphBuilder"),
                .target(name: "SymbolGraphTesting"),
            ]),

        .executableTarget(name: "SymbolGraphCompilerTests", dependencies:
            [
                .target(name: "SymbolGraphCompiler"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SymbolGraphPartTests", dependencies:
            [
                .target(name: "SymbolGraphParts"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SymbolGraphTests", dependencies:
            [
                .target(name: "SymbolGraphs"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SymbolTests", dependencies:
            [
                .target(name: "Symbols"),
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

        .executableTarget(name: "UnidocAnalysisTests", dependencies:
            [
                .target(name: "UnidocAnalysis"),
                .product(name: "BSONTesting", package: "swift-mongodb"),
            ]),

        .executableTarget(name: "UnidocDatabaseTests", dependencies:
            [
                .target(name: "UnidocDatabase"),
                .target(name: "SymbolGraphBuilder"),
                .target(name: "SymbolGraphTesting"),
                .product(name: "MongoTesting", package: "swift-mongodb"),
            ]),

        .executableTarget(name: "UnidocQueryTests", dependencies:
            [
                .target(name: "UnidocQueries"),
                .target(name: "SymbolGraphBuilder"),
                .target(name: "SymbolGraphTesting"),
                .product(name: "MongoTesting", package: "swift-mongodb"),
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

// swift-tools-version:5.9
import PackageDescription
import CompilerPluginSupport

let package:Package = .init(
    name: "swift-unidoc",
    platforms: [.macOS(.v11)],
    products:
    [
        .library(name: "guides", targets: ["guides"]),


        .library(name: "DynamicLookupMacros", targets: ["DynamicLookupMacros"]),
        .library(name: "IntegerEncodingMacros", targets: ["IntegerEncodingMacros"]),


        .library(name: "Availability", targets: ["Availability"]),
        .library(name: "AvailabilityDomain", targets: ["AvailabilityDomain"]),
        .library(name: "Codelinks", targets: ["Codelinks"]),
        .library(name: "CodelinkResolution", targets: ["CodelinkResolution"]),
        .library(name: "Doclinks", targets: ["Doclinks"]),
        .library(name: "DoclinkResolution", targets: ["DoclinkResolution"]),
        .library(name: "FNV1", targets: ["FNV1"]),

        .library(name: "GitHubAPI", targets: ["GitHubAPI"]),
        .library(name: "GitHubClient", targets: ["GitHubClient"]),

        .library(name: "HTML", targets: ["HTML"]),

        .library(name: "HTTP", targets: ["HTTP"]),
        .library(name: "HTTPClient", targets: ["HTTPClient"]),
        .library(name: "HTTPServer", targets: ["HTTPServer"]),

        .library(name: "IP", targets: ["IP"]),
        .library(name: "ISO", targets: ["ISO"]),
        .library(name: "InlineArray", targets: ["InlineArray"]),
        .library(name: "InlineBuffer", targets: ["InlineBuffer"]),
        .library(name: "InlineDictionary", targets: ["InlineDictionary"]),
        .library(name: "LexicalPaths", targets: ["LexicalPaths"]),

        .library(name: "MarkdownABI", targets: ["MarkdownABI"]),
        .library(name: "MarkdownAST", targets: ["MarkdownAST"]),
        .library(name: "MarkdownParsing", targets: ["MarkdownParsing"]),
        .library(name: "MarkdownRendering", targets: ["MarkdownRendering"]),
        .library(name: "MarkdownSemantics", targets: ["MarkdownSemantics"]),

        .library(name: "Media", targets: ["Media"]),

        .library(name: "MD5", targets: ["MD5"]),

        .library(name: "Multiparts", targets: ["Multiparts"]),

        .library(name: "PackageGraphs", targets: ["PackageGraphs"]),
        .library(name: "PackageMetadata", targets: ["PackageMetadata"]),

        .library(name: "S3", targets: ["S3"]),
        .library(name: "S3Client", targets: ["S3Client"]),

        .library(name: "SemanticVersions", targets: ["SemanticVersions"]),
        .library(name: "Signatures", targets: ["Signatures"]),
        .library(name: "Sitemaps", targets: ["Sitemaps"]),
        .library(name: "Sources", targets: ["Sources"]),

        .library(name: "Swiftinit", targets: ["Swiftinit"]),
        .library(name: "SwiftinitAssets", targets: ["SwiftinitAssets"]),
        .library(name: "SwiftinitPages", targets: ["SwiftinitPages"]),
        .library(name: "SwiftinitPlugins", targets: ["SwiftinitPlugins"]),
        .library(name: "SwiftinitRender", targets: ["SwiftinitRender"]),

        .executable(name: "SwiftinitServer", targets: ["SwiftinitServer"]),

        .library(name: "SymbolGraphBuilder", targets: ["SymbolGraphBuilder"]),
        .library(name: "SymbolGraphCompiler", targets: ["SymbolGraphCompiler"]),
        .library(name: "SymbolGraphLinker", targets: ["SymbolGraphLinker"]),
        .library(name: "SymbolGraphParts", targets: ["SymbolGraphParts"]),
        .library(name: "SymbolGraphs", targets: ["SymbolGraphs"]),
        .library(name: "Symbols", targets: ["Symbols"]),

        .library(name: "System", targets: ["System"]),

        .library(name: "UA", targets: ["UA"]),
        .library(name: "Unidoc", targets: ["Unidoc"]),
        .library(name: "UnidocAPI", targets: ["UnidocAPI"]),
        .library(name: "UnidocDB", targets: ["UnidocDB"]),
        .library(name: "UnidocDiagnostics", targets: ["UnidocDiagnostics"]),
        .library(name: "UnidocLinker", targets: ["UnidocLinker"]),
        .library(name: "UnidocQueries", targets: ["UnidocQueries"]),
        .library(name: "UnidocRecords", targets: ["UnidocRecords"]),

        .executable(name: "UnidocBuild", targets: ["UnidocBuild"]),

        .library(name: "URI", targets: ["URI"]),
    ],
    dependencies:
    [
        .package(url: "https://github.com/tayloraswift/swift-grammar", .upToNextMinor(
           from: "0.3.4")),

        .package(url: "https://github.com/tayloraswift/swift-hash", .upToNextMinor(
            from: "0.5.0")),
        .package(url: "https://github.com/tayloraswift/swift-mongodb", .upToNextMinor(
            from: "0.12.1")),
        //.package(path: "../swift-mongodb"),

        .package(url: "https://github.com/tayloraswift/swift-png", .upToNextMinor(
            from: "4.2.0")),

        .package(url: "https://github.com/apple/swift-atomics", .upToNextMinor(
            from: "1.2.0")),

        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(
            from: "1.1.0")),

        /// swift-nio has a low rate of breakage, and can be trusted with a major-only
        /// version requirement.
        .package(url: "https://github.com/apple/swift-nio",
            from: "2.63.0"),
        /// swift-nio-ssl has a low rate of breakage, and can be trusted with a
        /// major-only version requirement.
        .package(url: "https://github.com/apple/swift-nio-ssl",
            from: "2.26.0"),

        .package(url: "https://github.com/apple/swift-nio-http2", .upToNextMinor(
            from: "1.29.0")),
        .package(url: "https://github.com/apple/swift-markdown", .upToNextMinor(
            from: "0.3.0")),
        /// swift-system has broken in a minor before, and can't be trusted with a
        /// major-only version requirement.
        /// See: https://forums.swift.org/t/windows-build-is-broken/58036
        .package(url: "https://github.com/apple/swift-system", .upToNextMinor(
            from: "1.2.1")),
        .package(url: "https://github.com/apple/swift-syntax",
            exact: "509.1.1"),
    ],
    targets:
    [
        .target(name: "guides", path: "Guides"),


        .macro(name: "UnidocMacros",
            dependencies:
            [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ],
            path: "Plugins/UnidocMacros"),

        .target(name: "DynamicLookupMacros", dependencies:
            [
                .target(name: "UnidocMacros"),
            ],
            path: "Macros/DynamicLookupMacros"),

        .target(name: "IntegerEncodingMacros", dependencies:
            [
                .target(name: "UnidocMacros"),
            ],
            path: "Macros/IntegerEncodingMacros"),


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
                .target(name: "Symbols"),
                //  This dependency is present for (questionable?) performance reasons.
                .target(name: "Unidoc"),
            ]),

        .target(name: "Doclinks", dependencies:
            [
                .target(name: "URI"),
            ]),

        .target(name: "DoclinkResolution", dependencies:
            [
                .target(name: "Doclinks"),
                .target(name: "Symbols"),
            ]),

        .target(name: "FNV1"),

        .target(name: "GitHubClient", dependencies:
            [
                .target(name: "GitHubAPI"),
                .target(name: "HTTPClient"),

                .product(name: "Base64", package: "swift-hash"),
            ]),

        .target(name: "GitHubAPI", dependencies:
            [
                .target(name: "JSON"),
                .target(name: "UnixTime"),
            ]),

        .target(name: "HTML", dependencies:
            [
                .target(name: "DOM"),
            ]),

        .target(name: "DOM", dependencies:
            [
                .target(name: "DynamicLookupMacros"),
            ]),

        .target(name: "HTTP", dependencies:
            [
                .target(name: "ISO"),
                .target(name: "Media"),
                .target(name: "MD5"),

                .product(name: "NIOCore", package: "swift-nio"),
            ]),

        .target(name: "HTTPClient", dependencies:
            [
                .target(name: "HTML"),
                .target(name: "HTTP"),
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
                .target(name: "IP"),
                .target(name: "UA"),

                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOHTTP2", package: "swift-nio-http2"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),

        .target(name: "IP"),

        .target(name: "InlineArray"),

        .target(name: "InlineBuffer"),

        .target(name: "InlineDictionary"),

        .target(name: "ISO", dependencies:
            [
                .target(name: "IntegerEncodingMacros"),
            ]),

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
                .target(name: "URI"),
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
                .target(name: "Signatures"),
                .target(name: "Snippets"),
                .target(name: "Symbols"),

                .product(name: "SwiftIDEUtils", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ]),

        .target(name: "MarkdownSemantics", dependencies:
            [
                .target(name: "Codelinks"),
                .target(name: "MarkdownAST"),
                .target(name: "Sources"),
                .target(name: "Snippets"),
                .target(name: "UnidocDiagnostics"),

                .product(name: "OrderedCollections", package: "swift-collections"),
            ]),

        .target(name: "MD5", dependencies:
            [
                .target(name: "InlineBuffer"),
            ]),

        .target(name: "Media"),

        .target(name: "Multiparts", dependencies:
            [
                .target(name: "Media"),
                .product(name: "Grammar", package: "swift-grammar"),
            ]),

        .target(name: "PackageGraphs", dependencies:
            [
                .target(name: "SymbolGraphs"),
            ]),

        .target(name: "PackageMetadata", dependencies:
            [
                .target(name: "JSON"),
                .target(name: "PackageGraphs"),
            ]),

        .target(name: "S3", dependencies:
            [
            ]),

        .target(name: "S3Client", dependencies:
            [
                .target(name: "HTTPClient"),
                .target(name: "Media"),
                .target(name: "S3"),
                .target(name: "UnixTime"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "SHA2", package: "swift-hash"),
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

        .target(name: "Sitemaps", dependencies:
            [
                .target(name: "DOM"),
            ]),

        .target(name: "Snippets", dependencies:
            [
                .target(name: "MarkdownABI"),
            ]),

        .target(name: "Sources"),

        .target(name: "Swiftinit", dependencies:
            [
                .target(name: "URI"),
            ]),

        .target(name: "SwiftinitAssets", dependencies:
            [
                .target(name: "SwiftinitPages"),
                .target(name: "System"),
            ]),

        .target(name: "SwiftinitPages", dependencies:
            [
                .target(name: "GitHubAPI"),
                .target(name: "SwiftinitRender"),
                .target(name: "UnidocAPI"),
                .target(name: "UnidocProfiling"),
                .target(name: "UnidocQueries"),
            ]),

        .target(name: "SwiftinitPlugins", dependencies:
            [
                .target(name: "SwiftinitRender"),
                .target(name: "UnidocDB"),

                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
            ]),

        .target(name: "SwiftinitRender", dependencies:
            [
                .target(name: "HTTP"),
                .target(name: "HTML"),
                .target(name: "MarkdownRendering"),
                .target(name: "Media"),
                .target(name: "Swiftinit"),
                .target(name: "UnidocRecords"),
            ]),

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
                .target(name: "InlineArray"),
                .target(name: "InlineDictionary"),
                .target(name: "MarkdownParsing"),
                .target(name: "MarkdownRendering"),
                .target(name: "MarkdownSemantics"),
                .target(name: "SemanticVersions"),
                .target(name: "SHA1"),
                .target(name: "Snippets"),
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
                //  This is the point where the symbol graph compiler becomes infected with a
                //  (non-macro) SwiftSyntax dependency.
                //
                //  This also means that the static symbol graph linker can freely use any
                //  of the SwiftSyntax-powered plugins, since we have already paid for the
                //  dependency.
                .target(name: "MarkdownPluginSwift"),
                .target(name: "Signatures"),
                .target(name: "Symbols"),
            ]),

        .target(name: "SymbolGraphs", dependencies:
            [
                .target(name: "LexicalPaths"),
                .target(name: "SemanticVersions"),
                .target(name: "SHA1"),
                .target(name: "Signatures"),
                .target(name: "Symbols"),

                .product(name: "BSON", package: "swift-mongodb"),
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

        .target(name: "UA", dependencies:
            [
                .product(name: "Grammar", package: "swift-grammar"),
            ]),

        .target(name: "Unidoc"),

        .target(name: "UnidocAPI", dependencies:
            [
                .target(name: "JSON"),
                .target(name: "Unidoc"),
            ]),

        .target(name: "UnidocDB", dependencies:
            [
                .target(name: "GitHubAPI"),
                .target(name: "UnidocLinker"),
                .target(name: "UnixTime"),
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
                .target(name: "MarkdownRendering"),
                .target(name: "UnidocDiagnostics"),
                .target(name: "UnidocRecords"),
            ]),

        .target(name: "UnidocProfiling", dependencies:
            [
                .target(name: "HTTPServer"),
                .target(name: "MarkdownRendering"),
                .target(name: "Media"),
                .target(name: "UA"),
            ]),

        .target(name: "UnidocQueries", dependencies:
            [
                .target(name: "UnidocDB"),
                .target(name: "UnidocRecords"),
            ]),

        .target(name: "UnidocRecords", dependencies:
            [
                .target(name: "FNV1"),
                .target(name: "MD5"),
                .target(name: "SymbolGraphs"),
                .target(name: "UnidocAPI"),
            ]),

        .target(name: "UnixTime"),

        .target(name: "URI", dependencies:
            [
                .product(name: "Grammar", package: "swift-grammar"),
            ]),

        .target(name: "System", dependencies:
            [
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),


        .executableTarget(name: "S3Export", dependencies:
            [
                .target(name: "S3Client"),
                .target(name: "System"),
                .target(name: "SwiftinitAssets"),
            ]),

        .executableTarget(name: "UnidocBuild", dependencies:
            [
                .target(name: "HTTPClient"),
                .target(name: "SymbolGraphBuilder"),
                .target(name: "UnidocLinker"),
                .target(name: "UnidocRecords"),
            ]),

        .executableTarget(name: "SwiftinitServer", dependencies:
            [
                .target(name: "GitHubClient"),
                .target(name: "HTTPServer"),
                .target(name: "Multiparts"),
                .target(name: "S3Client"),
                .target(name: "Sitemaps"),
                .target(name: "SwiftinitAssets"),
                .target(name: "SwiftinitPages"),
                .target(name: "SwiftinitPlugins"),
                .product(name: "LZ77", package: "swift-png"),
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

        .executableTarget(name: "IPTests", dependencies:
            [
                .target(name: "IP"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "MarkdownParsingTests", dependencies:
            [
                .target(name: "MarkdownParsing"),
                .target(name: "MarkdownSemantics"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "MarkdownPluginSwiftTests", dependencies:
            [
                .target(name: "MarkdownPluginSwift"),
                .target(name: "MarkdownRendering"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "MarkdownRenderingTests", dependencies:
            [
                .target(name: "MarkdownRendering"),
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

        .executableTarget(name: "S3Tests", dependencies:
            [
                .target(name: "S3Client"),
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

        .executableTarget(name: "SymbolGraphLinkerTests", dependencies:
            [
                .target(name: "HTML"),
                .target(name: "MarkdownRendering"),
                .target(name: "SymbolGraphLinker"),
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

        .executableTarget(name: "UATests", dependencies:
            [
                .target(name: "UA"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "UnidocRecordsTests", dependencies:
            [
                .target(name: "UnidocRecords"),
                .product(name: "BSONTesting", package: "swift-mongodb"),
            ]),

        .executableTarget(name: "UnidocDBTests", dependencies:
            [
                .target(name: "UnidocDB"),
                .target(name: "GitHubClient"),
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
        settings.append(.enableExperimentalFeature("NestedProtocols"))
        settings.append(.enableExperimentalFeature("StrictConcurrency"))

        settings.append(.define("DEBUG", .when(configuration: .debug)))

        $0 = settings
    } (&target.swiftSettings)
}

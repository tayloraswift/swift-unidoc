// swift-tools-version:5.10
import PackageDescription
import CompilerPluginSupport

let package:Package = .init(
    name: "swift-unidoc",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "ssgc", targets: ["ssgc"]),
        .executable(name: "unidoc-build", targets: ["unidoc-build"]),
        .executable(name: "SwiftinitServer", targets: ["SwiftinitServer"]),

        .library(name: "guides", targets: ["guides"]),

        .library(name: "CasesByIntegerEncodingMacro", targets: ["CasesByIntegerEncodingMacro"]),

        .library(name: "Availability", targets: ["Availability"]),
        .library(name: "AvailabilityDomain", targets: ["AvailabilityDomain"]),
        .library(name: "Codelinks", targets: ["Codelinks"]),
        .library(name: "CodelinkResolution", targets: ["CodelinkResolution"]),
        .library(name: "Doclinks", targets: ["Doclinks"]),
        .library(name: "DoclinkResolution", targets: ["DoclinkResolution"]),
        .library(name: "FNV1", targets: ["FNV1"]),

        .library(name: "GitHubAPI", targets: ["GitHubAPI"]),
        .library(name: "GitHubClient", targets: ["GitHubClient"]),

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
        .library(name: "SourceDiagnostics", targets: ["SourceDiagnostics"]),
        .library(name: "Sources", targets: ["Sources"]),

        .library(name: "Swiftinit", targets: ["Swiftinit"]),
        .library(name: "SwiftinitAssets", targets: ["SwiftinitAssets"]),
        .library(name: "SwiftinitPages", targets: ["SwiftinitPages"]),
        .library(name: "SwiftinitPlugins", targets: ["SwiftinitPlugins"]),
        .library(name: "SwiftinitRender", targets: ["SwiftinitRender"]),

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
        .library(name: "UnidocLinker", targets: ["UnidocLinker"]),
        .library(name: "UnidocQueries", targets: ["UnidocQueries"]),
        .library(name: "UnidocRecords", targets: ["UnidocRecords"]),

        .library(name: "URI", targets: ["URI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tayloraswift/swift-dom", .upToNextMinor(
            from: "0.6.1")),
        .package(url: "https://github.com/tayloraswift/swift-grammar", .upToNextMinor(
            from: "0.3.4")),
        .package(url: "https://github.com/tayloraswift/swift-hash", .upToNextMinor(
            from: "0.5.0")),
        .package(url: "https://github.com/tayloraswift/swift-mongodb", .upToNextMinor(
            from: "0.14.0")),
        //.package(path: "../swift-mongodb"),

        .package(url: "https://github.com/tayloraswift/swift-json", .upToNextMinor(
            from: "1.0.0")),

        .package(url: "https://github.com/tayloraswift/swift-png", .upToNextMinor(
            from: "4.4.1")),

        .package(url: "https://github.com/apple/swift-atomics", .upToNextMinor(
            from: "1.2.0")),

        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(
            from: "1.1.0")),

        /// swift-nio has a low rate of breakage, and can be trusted with a major-only
        /// version requirement.
        .package(url: "https://github.com/apple/swift-nio",
            from: "2.64.0"),
        /// swift-nio-ssl has a low rate of breakage, and can be trusted with a
        /// major-only version requirement.
        .package(url: "https://github.com/apple/swift-nio-ssl",
            from: "2.26.0"),

        .package(url: "https://github.com/apple/swift-nio-http2", .upToNextMinor(
            from: "1.30.0")),
        .package(url: "https://github.com/apple/swift-markdown", .upToNextMinor(
            from: "0.3.0")),
        /// swift-system has broken in a minor before, and can't be trusted with a
        /// major-only version requirement.
        /// See: https://forums.swift.org/t/windows-build-is-broken/58036
        .package(url: "https://github.com/apple/swift-system", .upToNextMinor(
            from: "1.2.1")),
        .package(url: "https://github.com/apple/swift-syntax",
            exact: "510.0.1"),
    ],
    targets: [
        .target(name: "guides", path: "Guides"),


        .macro(name: "UnidocMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ],
            path: "Macros/UnidocMacros"),

        .target(name: "CasesByIntegerEncodingMacro",
            dependencies: [
                .target(name: "UnidocMacros"),
            ],
            path: "Macros/CasesByIntegerEncodingMacro"),


        .target(name: "_AsyncChannel",
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]),

        .target(name: "ArgumentParsing"),

        .target(name: "AvailabilityDomain"),

        .target(name: "Availability",
            dependencies: [
                .target(name: "AvailabilityDomain"),
                .target(name: "SemanticVersions"),
            ]),

        .target(name: "Codelinks",
            dependencies: [
                .target(name: "FNV1"),
                .target(name: "LexicalPaths"),
            ]),

        .target(name: "CodelinkResolution",
            dependencies: [
                .target(name: "Codelinks"),
                .target(name: "SourceDiagnostics"),
                //  This dependency is present for (questionable?) performance reasons.
                .target(name: "Unidoc"),
            ]),

        .target(name: "Doclinks",
            dependencies: [
                .target(name: "URI"),
            ]),

        .target(name: "DoclinkResolution",
            dependencies: [
                .target(name: "Doclinks"),
                .target(name: "Symbols"),
            ]),

        .target(name: "DynamicTime"),

        .target(name: "FNV1"),

        .target(name: "GitHubClient",
            dependencies: [
                .target(name: "GitHubAPI"),
                .target(name: "HTTPClient"),

                .product(name: "Base64", package: "swift-hash"),
            ]),

        .target(name: "GitHubAPI",
            dependencies: [
                .target(name: "UnixTime"),
                .target(name: "SHA1"),
                .product(name: "JSON", package: "swift-json"),
            ]),

        .target(name: "HTTP",
            dependencies: [
                .target(name: "ISO"),
                .target(name: "Media"),
                .target(name: "MD5"),

                .product(name: "NIOCore", package: "swift-nio"),
            ]),

        .target(name: "HTTPClient",
            dependencies: [
                .target(name: "HTTP"),
                .target(name: "Media"),
                .target(name: "MD5"),
                .product(name: "HTML", package: "swift-dom"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOHTTP2", package: "swift-nio-http2"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),

        .target(name: "HTTPServer",
            dependencies: [
                .target(name: "_AsyncChannel"),

                .target(name: "HTTP"),
                .target(name: "IP"),
                .target(name: "UA"),

                .product(name: "HTML", package: "swift-dom"),
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

        .target(name: "ISO",
            dependencies: [
                .target(name: "CasesByIntegerEncodingMacro"),
            ]),

        .target(name: "LexicalPaths"),

        .target(name: "MarkdownABI"),

        .target(name: "MarkdownAST",
            dependencies: [
                .target(name: "MarkdownABI"),
                .target(name: "Sources"),
            ]),

        .target(name: "MarkdownDisplay",
            dependencies: [
                .target(name: "MarkdownABI"),
            ]),

        .target(name: "MarkdownRendering",
            dependencies: [
                .target(name: "MarkdownABI"),
                .target(name: "URI"),
                .product(name: "HTML", package: "swift-dom"),
            ]),

        .target(name: "MarkdownParsing",
            dependencies: [
                .target(name: "MarkdownAST"),
                .target(name: "SourceDiagnostics"),
                //  TODO: this links Foundation. Need to find a replacement.
                .product(name: "Markdown", package: "swift-markdown"),
            ]),

        .target(name: "MarkdownPluginSwift",
            dependencies: [
                .target(name: "MarkdownABI"),
                .target(name: "Signatures"),
                .target(name: "Snippets"),
                .target(name: "Symbols"),

                .product(name: "SwiftIDEUtils", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ]),

        .target(name: "MarkdownSemantics",
            dependencies: [
                .target(name: "Codelinks"),
                .target(name: "Doclinks"),
                .target(name: "MarkdownAST"),
                .target(name: "MarkdownDisplay"),
                .target(name: "Snippets"),
                .target(name: "SourceDiagnostics"),

                .product(name: "OrderedCollections", package: "swift-collections"),
            ]),

        .target(name: "MD5",
            dependencies: [
                .target(name: "InlineBuffer"),
            ]),

        .target(name: "Media"),

        .target(name: "Multiparts",
            dependencies: [
                .target(name: "Media"),
                .product(name: "Grammar", package: "swift-grammar"),
            ]),

        .target(name: "PackageGraphs",
            dependencies: [
                .target(name: "SymbolGraphs"),
            ]),

        .target(name: "PackageMetadata",
            dependencies: [
                .target(name: "PackageGraphs"),
                .product(name: "JSON", package: "swift-json"),
            ]),

        .target(name: "S3",
            dependencies: [
            ]),

        .target(name: "S3Client",
            dependencies: [
                .target(name: "HTTPClient"),
                .target(name: "Media"),
                .target(name: "S3"),
                .target(name: "UnixTime"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "SHA2", package: "swift-hash"),
            ]),

        .target(name: "SemanticVersions"),

        .target(name: "SHA1",
            dependencies: [
                .target(name: "InlineBuffer"),
            ]),

        .target(name: "Signatures",
            dependencies: [
                .target(name: "Availability"),
                .target(name: "MarkdownABI")
            ]),

        .target(name: "Sitemaps",
            dependencies: [
                .product(name: "DOM", package: "swift-dom"),
            ]),

        .target(name: "Snippets",
            dependencies: [
                .target(name: "MarkdownABI"),
            ]),

        .target(name: "Sources"),

        .target(name: "Swiftinit",
            dependencies: [
                .target(name: "URI"),
            ]),

        .target(name: "SwiftinitAssets",
            dependencies: [
                .target(name: "SwiftinitPages"),
                .target(name: "System"),
            ]),

        .target(name: "SwiftinitPages",
            dependencies: [
                .target(name: "DynamicTime"),
                .target(name: "GitHubAPI"),
                .target(name: "SwiftinitRender"),
                .target(name: "UnidocAPI"),
                .target(name: "UnidocProfiling"),
                .target(name: "UnidocQueries"),
            ]),

        .target(name: "SwiftinitPlugins",
            dependencies: [
                .target(name: "SwiftinitRender"),
                .target(name: "UnidocDB"),

                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
            ]),

        .target(name: "SwiftinitRender",
            dependencies: [
                .target(name: "HTTP"),
                .target(name: "MarkdownDisplay"),
                .target(name: "MarkdownRendering"),
                .target(name: "Media"),
                .target(name: "Swiftinit"),
                .target(name: "UnidocRecords"),
                .product(name: "HTML", package: "swift-dom"),
            ]),

        .target(name: "Symbols",
            dependencies: [
                .target(name: "FNV1"),
                .target(name: "Sources"),
            ]),

        .target(name: "SymbolGraphBuilder",
            dependencies: [
                .target(name: "ArgumentParsing"),
                .target(name: "MarkdownPluginSwift"),
                .target(name: "PackageMetadata"),
                .target(name: "SymbolGraphCompiler"),
                .target(name: "SymbolGraphLinker"),
                .target(name: "System"),
            ]),

        .target(name: "SymbolGraphCompiler",
            dependencies: [
                .target(name: "SymbolGraphParts"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),

        .target(name: "SymbolGraphLinker",
            dependencies: [
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
                .target(name: "SourceDiagnostics"),
                .target(name: "URI"),
            ]),

        .target(name: "SymbolGraphParts",
            dependencies: [
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
                .product(name: "JSON", package: "swift-json"),
            ]),

        .target(name: "SymbolGraphs",
            dependencies: [
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

        .target(name: "SymbolGraphTesting",
            dependencies: [
                .target(name: "SymbolGraphs"),
                .target(name: "System"),

                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .target(name: "UA",
            dependencies: [
                .product(name: "Grammar", package: "swift-grammar"),
            ]),

        .target(name: "Unidoc"),

        .target(name: "UnidocAPI",
            dependencies: [
                .target(name: "SemanticVersions"),
                .target(name: "Symbols"),
                .target(name: "Unidoc"),
                .target(name: "URI"),
                .product(name: "JSON", package: "swift-json"),
            ]),

        .target(name: "UnidocDB",
            dependencies: [
                .target(name: "GitHubAPI"),
                .target(name: "UnidocRecords_LZ77"),
                .target(name: "UnidocLinker"),
                .target(name: "UnidocRecords"),
                .target(name: "UnixTime"),
                .product(name: "MongoDB", package: "swift-mongodb"),
            ]),

        .target(name: "UnidocRecords_LZ77",
            dependencies: [
                .target(name: "UnidocRecords"),
                .product(name: "LZ77", package: "swift-png"),
            ]),

        .target(name: "SourceDiagnostics",
            dependencies: [
                .target(name: "Symbols"),
                .target(name: "Sources"),
            ]),

        .target(name: "UnidocLinker",
            dependencies: [
                .target(name: "CodelinkResolution"),
                .target(name: "DoclinkResolution"),
                .target(name: "MarkdownRendering"),
                .target(name: "UnidocRecords"),
            ]),

        .target(name: "UnidocProfiling",
            dependencies: [
                .target(name: "HTTPServer"),
                .target(name: "MarkdownRendering"),
                .target(name: "Media"),
                .target(name: "UA"),
            ]),

        .target(name: "UnidocQueries",
            dependencies: [
                .target(name: "UnidocDB"),
                .target(name: "UnidocRecords"),
            ]),

        .target(name: "UnidocRecords",
            dependencies: [
                .target(name: "FNV1"),
                .target(name: "MD5"),
                .target(name: "SymbolGraphs"),
                .target(name: "UnidocAPI"),
            ]),

        .target(name: "UnixTime"),

        .target(name: "URI",
            dependencies: [
                .product(name: "Grammar", package: "swift-grammar"),
            ]),

        .target(name: "System",
            dependencies: [
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),


        .executableTarget(name: "S3Export",
            dependencies: [
                .target(name: "S3Client"),
                .target(name: "System"),
                .target(name: "SwiftinitAssets"),
            ]),

        .executableTarget(name: "ssgc",
            dependencies: [
                .target(name: "ArgumentParsing"),
                .target(name: "SymbolGraphBuilder"),
            ]),

        .executableTarget(name: "unidoc-build",
            dependencies: [
                .target(name: "ArgumentParsing"),
                .target(name: "HTTPClient"),
                .target(name: "SymbolGraphBuilder"),
                .target(name: "UnidocRecords_LZ77"),
                .target(name: "UnidocRecords"),
            ]),

        .executableTarget(name: "SwiftinitRelay",
            dependencies: [
                .target(name: "ArgumentParsing"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ]),

        .executableTarget(name: "SwiftinitServer",
            dependencies: [
                .target(name: "ArgumentParsing"),
                .target(name: "GitHubClient"),
                .target(name: "HTTPServer"),
                .target(name: "Media"),
                .target(name: "Multiparts"),
                .target(name: "S3Client"),
                .target(name: "Sitemaps"),
                .target(name: "SwiftinitAssets"),
                .target(name: "SwiftinitPages"),
                .target(name: "SwiftinitPlugins"),
                .target(name: "UnidocAPI"),
                .target(name: "UnidocQueries"),
            ]),


        .executableTarget(name: "CodelinkTests",
            dependencies: [
                .target(name: "Codelinks"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "DoclinkTests",
            dependencies: [
                .target(name: "Doclinks"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "FNV1Tests",
            dependencies: [
                .target(name: "FNV1"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "IPTests",
            dependencies: [
                .target(name: "IP"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "MarkdownParsingTests",
            dependencies: [
                .target(name: "MarkdownParsing"),
                .target(name: "MarkdownSemantics"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "MarkdownPluginSwiftTests",
            dependencies: [
                .target(name: "MarkdownPluginSwift"),
                .target(name: "MarkdownRendering"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "MarkdownRenderingTests",
            dependencies: [
                .target(name: "MarkdownRendering"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "MD5Tests",
            dependencies: [
                .target(name: "MD5"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "PackageMetadataTests",
            dependencies: [
                .target(name: "PackageMetadata"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "S3Tests",
            dependencies: [
                .target(name: "S3Client"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SemanticVersionTests",
            dependencies: [
                .target(name: "SemanticVersions"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SymbolGraphBuilderTests",
            dependencies: [
                .target(name: "SymbolGraphBuilder"),
                .target(name: "SymbolGraphTesting"),
            ]),

        .executableTarget(name: "SymbolGraphCompilerTests",
            dependencies: [
                .target(name: "SymbolGraphCompiler"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SymbolGraphLinkerTests",
            dependencies: [
                .target(name: "MarkdownRendering"),
                .target(name: "SymbolGraphLinker"),
                .product(name: "HTML", package: "swift-dom"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SymbolGraphPartTests",
            dependencies: [
                .target(name: "SymbolGraphParts"),
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SymbolGraphTests",
            dependencies: [
                .target(name: "SymbolGraphs"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SymbolTests",
            dependencies: [
                .target(name: "Symbols"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "SystemTests",
            dependencies: [
                .target(name: "System"),
                .product(name: "Testing", package: "swift-grammar"),
            ],
            exclude:
            [
                "directories",
            ]),

        .executableTarget(name: "UATests",
            dependencies: [
                .target(name: "UA"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "UnidocRecordsTests",
            dependencies: [
                .target(name: "UnidocRecords"),
                .product(name: "BSONTesting", package: "swift-mongodb"),
            ]),

        .executableTarget(name: "UnidocDBTests",
            dependencies: [
                .target(name: "UnidocDB"),
                .target(name: "GitHubClient"),
                .target(name: "SymbolGraphBuilder"),
                .target(name: "SymbolGraphTesting"),
                .product(name: "MongoTesting", package: "swift-mongodb"),
            ]),

        .executableTarget(name: "UnidocQueryTests",
            dependencies: [
                .target(name: "UnidocQueries"),
                .target(name: "SymbolGraphBuilder"),
                .target(name: "SymbolGraphTesting"),
                .product(name: "MongoTesting", package: "swift-mongodb"),
            ]),

        .executableTarget(name: "URITests",
            dependencies: [
                .target(name: "URI"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),
    ])

for target:PackageDescription.Target in package.targets
{
    if  target.name == "_AsyncChannel"
    {
        continue
    }

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

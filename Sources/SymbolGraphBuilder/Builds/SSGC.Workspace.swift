import MarkdownABI
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

extension SSGC
{
    @frozen public
    struct Workspace:Equatable
    {
        public
        let path:FilePath

        private
        init(path:FilePath)
        {
            self.path = path
        }
    }
}
extension SSGC.Workspace
{
    @inlinable public
    var artifacts:FilePath { self.path / "artifacts" }
    @inlinable public
    var checkouts:FilePath { self.path / "checkouts" }
}
extension SSGC.Workspace
{
    public static
    func existing(at location:FilePath) -> Self
    {
        .init(path: location)
    }

    public static
    func create(at location:FilePath) throws -> Self
    {
        let workspace:Self = .init(path: location)
        try workspace.artifacts.directory.create()
        try workspace.checkouts.directory.create()
        return workspace
    }
}
extension SSGC.Workspace
{
    public
    func build(package build:SSGC.PackageBuild,
        with swift:SSGC.Toolchain) throws -> SymbolGraphObject<Void>
    {
        try self.build(some: build, toolchain: swift, logger: nil, status: nil)
    }

    public
    func build(special build:SSGC.SpecialBuild,
        with swift:SSGC.Toolchain) throws -> SymbolGraphObject<Void>
    {
        try self.build(some: build, toolchain: swift, logger: nil, status: nil)
    }
}
extension SSGC.Workspace
{
    func build<Build>(some build:consuming Build,
        toolchain swift:SSGC.Toolchain,
        logger:SSGC.DocumentationLogger?,
        status:SSGC.StatusStream?) throws -> SymbolGraphObject<Void>
        where Build:SSGC.DocumentationBuild
    {
        let metadata:SymbolGraphMetadata
        let package:Build.Sources

        let output:FilePath = self.artifacts
        try output.directory.create(clean: true)

        (metadata, package) = try build.compile(updating: status,
            into: output.directory,
            with: swift)

        let symbols:[Symbol.Module: [SymbolGraphPart.ID]] = try output.directory.reduce(
            into: [:])
        {
            //  We don’t want to *parse* the JSON yet to discover the culture,
            //  because the JSON can be very large, and parsing JSON is very
            //  expensive (compared to parsing BSON). So we trust that the file
            //  name is correct and indicates what is contained within the file.
            let filename:FilePath.Component = try $1.get()
            guard
            let id:SymbolGraphPart.ID = .init("\(filename)")
            else
            {
                return
            }

            switch id.namespace
            {
            case    "CDispatch",                    // too low-level
                    "CFURLSessionInterface",        // too low-level
                    "CFXMLInterface",               // too low-level
                    "CoreFoundation",               // too low-level
                    "Glibc",                        // linux-gnu specific
                    "SwiftGlibc",                   // linux-gnu specific
                    "SwiftOnoneSupport",            // contains no symbols
                    "SwiftOverlayShims",            // too low-level
                    "SwiftShims",                   // contains no symbols
                    "_Builtin_intrinsics",          // contains only one symbol, free(_:)
                    "_Builtin_stddef_max_align_t",  // contains only two symbols
                    "_InternalStaticMirror",        // unbuildable
                    "_InternalSwiftScan",           // unbuildable
                    "_SwiftConcurrencyShims",       // contains only two symbols
                    "std":                          // unbuildable
                return

            default:
                $0[id.culture, default: []].append(id)
            }
        }

        let compiled:SymbolGraph = try .compile(artifacts: package.cultures.map
            {
                .init(parts: symbols[$0.module.id, default: []], in: output)
            },
            package: package,
            logger: logger,
            index: try package.indexStore(for: swift))

        return .init(metadata: metadata, graph: compiled)
    }
}

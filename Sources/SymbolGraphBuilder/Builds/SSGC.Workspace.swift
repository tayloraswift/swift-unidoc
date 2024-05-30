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
        let location:FilePath.Directory

        private
        init(absolute location:FilePath.Directory)
        {
            self.location = location
        }
    }
}
extension SSGC.Workspace
{
    @inlinable public
    var artifacts:FilePath.Directory { self.location / "artifacts" }
    @inlinable public
    var checkouts:FilePath.Directory { self.location / "checkouts" }
}
extension SSGC.Workspace
{
    private
    init(location:FilePath.Directory)
    {
        if  location.path.isAbsolute
        {
            self.init(absolute: location)
        }
        else if
            let current:FilePath.Directory = .current()
        {
            self.init(absolute: .init(path: current.path.appending(location.path.components)))
        }
        else
        {
            fatalError("Couldn’t determine the current working directory.")
        }
    }

    public static
    func existing(at location:FilePath.Directory) -> Self
    {
        .init(location: location)
    }

    public static
    func create(at location:FilePath.Directory) throws -> Self
    {
        let workspace:Self = .init(location: location)
        try workspace.artifacts.create()
        try workspace.checkouts.create()
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

        let output:FilePath.Directory = self.artifacts
        try output.create(clean: true)

        (metadata, package) = try build.compile(updating: status,
            into: output,
            with: swift)

        let symbols:[Symbol.Module: [SymbolGraphPart.ID]] = try output.reduce(
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
                .init(location: output, parts: symbols[$0.module.id, default: []])
            },
            package: package,
            logger: logger,
            index: try package.indexStore(for: swift))

        return .init(metadata: metadata, graph: compiled)
    }
}

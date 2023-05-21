import PackageGraphs
import SemanticVersions
import System

@frozen public
struct Workspace:Equatable
{
    public
    let path:FilePath

    @inlinable public
    init(path:FilePath)
    {
        self.path = path
    }
}
extension Workspace
{
    public static
    func create(at path:FilePath) async throws -> Self
    {
        try await SystemProcess.init(command: "mkdir", "-p", "\(path)")()
        return .init(path: path)
    }

    public
    func clean() async throws
    {
        try await SystemProcess.init(command: "rm", "-f", "\(self.path.appending("*"))")()
    }
}
extension Workspace
{
    /// Creates a nested workspace directory within this one.
    public
    func create(_ name:String, clean:Bool = false) async throws -> Self
    {
        let workspace:Self = try await .create(at: self.path / name)
        if  clean { try await workspace.clean() }
        return workspace
    }

    public
    func checkout(url:String,
        at ref:String,
        clean:Bool = false) async throws -> RepositoryCheckout
    {
        guard let package:PackageIdentifier = .infer(from: url)
        else
        {
            fatalError("unimplemented")
        }

        let root:FilePath = self.path / "\(package)"
        do
        {
            try await SystemProcess.init(command: "git", "-C", root.string, "fetch")()
        }
        catch SystemProcessError.exit
        {
            try await SystemProcess.init(command: "git", "-C", self.path.string,
                "clone", url, package.description)()
        }

        let workspace:Self = try await self.create("\(package).doc", clean: clean)

        try await SystemProcess.init(command: "git", "-C", root.string, "checkout", ref)()

        let (readable, writable):(FileDescriptor, FileDescriptor) =
            try FileDescriptor.pipe()

        defer
        {
            try? writable.close()
            try? readable.close()
        }

        try await SystemProcess.init(command: "git", "-C", root.string,
            "rev-list", "-n", "1", ref,
            stdout: writable)()

        //  Note: output contains trailing newline
        let output:String = try .init(unsafeUninitializedCapacity: 64)
        {
            try readable.read(into: .init($0))
        }

        guard let revision:Repository.Revision = .init(output.prefix(while: \.isHexDigit))
        else
        {
            fatalError("unimplemented")
        }

        return .init(workspace: workspace,
            root: root,
            pin: .init(id: package,
                location: .remote(url: url),
                revision: revision,
                ref: .infer(from: ref)))
    }
}
extension Workspace
{
    /// Dumps the symbols for the given targets, using this workspace as the
    /// output directory.
    func dumpSymbols(targets:[TargetNode],
        include buildDirectory:FilePath? = nil,
        triple:Triple,
        pretty:Bool = false) async throws -> [DocumentationArtifacts.Culture]
    {
        for target:TargetNode in targets
        {
            print("Dumping symbols for module '\(target.id)'")

            var arguments:[String] =
            [
                "symbolgraph-extract",

                "-module-name",                     "\(target.id)",
                "-target",                          "\(triple)",
                "-minimum-access-level",            "internal",
                "-output-dir",                      "\(self.path)",
                "-emit-extension-block-symbols",
                "-include-spi-symbols",
                "-skip-inherited-docs",
            ]
            if  pretty
            {
                arguments.append("-pretty-print")
            }
            if  let buildDirectory:FilePath
            {
                arguments.append("-I")
                arguments.append("\(buildDirectory)")
            }

            try await SystemProcess.init(command: "swift", arguments: arguments)()
        }

        let blacklisted:Set<ModuleIdentifier> =
        [
            "CDispatch",                    // too low-level
            "CFURLSessionInterface",        // too low-level
            "CFXMLInterface",               // too low-level
            "CoreFoundation",               // too low-level
            "Glibc",                        // linux-gnu specific
            "SwiftGlibc",                   // linux-gnu specific
            "SwiftOnoneSupport",            // contains no symbols
            "SwiftOverlayShims",            // too low-level
            "SwiftShims",                   // contains no symbols
            "XCTest",                       // site policy
            "_Builtin_intrinsics",          // contains only one symbol, free(_:)
            "_Builtin_stddef_max_align_t",  // contains only two symbols
            "_InternalStaticMirror",        // unbuildable
            "_InternalSwiftScan",           // unbuildable
            "_SwiftConcurrencyShims",       // contains only two symbols
            "std",                          // unbuildable
        ]

        var parts:[ModuleIdentifier: [FilePath.Component]] = [:]
        for part:Result<FilePath.Component, any Error> in self.path.directory
        {
            let part:FilePath.Component = try part.get()
            let names:[Substring] = part.string.split(separator: ".")
            //  We don’t want to *parse* the JSON yet to discover the culture,
            //  because the JSON can be very large, and parsing JSON is very
            //  expensive (compared to parsing BSON). So we trust that the
            //  file name is correct and indicates what is contained within the
            //  file.
            if  names.count == 3,
                names[1 ... 2] == ["symbols", "json"]
            {
                let components:[Substring] = names[0].split(separator: "@", maxSplits: 1)
                if  components.count == 2,
                    blacklisted.contains(.init(String.init(components[1])))
                {
                    continue
                }
                guard let culture:Substring = components.first
                else
                {
                    continue
                }

                parts[.init(String.init(culture)), default: []].append(part)
            }
        }
        for parts:[FilePath.Component] in parts.sorted(by: { $0.key < $1.key }).map(\.value)
        {
            for artifact:String in parts.map(\.string).sorted()
            {
                print("Note: including artifact '\(artifact)'")
            }
        }

        return try targets.map
        {
            try .init(
                parts: parts[$0.id, default: []].map { self.path / $0 },
                node: $0)
        }
    }
}

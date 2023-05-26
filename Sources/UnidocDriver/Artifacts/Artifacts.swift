import ModuleGraphs
import PackageGraphs
import PackageMetadata
import System

public
struct Artifacts
{
    let cultures:[Culture]
    let root:Repository.Root?

    private
    init(cultures:[Culture], root:Repository.Root? = nil)
    {
        self.cultures = cultures
        self.root = root
    }
}
extension Artifacts
{
    /// Dumps the symbols for the given targets, using this workspace as the
    /// output directory.
    public static
    func dump(modules:[ModuleStack],
        output:Workspace,
        triple:Triple,
        pretty:Bool = false) async throws -> Self
    {
        .init(cultures: try await Self.dump(from: modules.map { .init($0) },
                output: output,
                triple: triple,
                pretty: pretty))
    }
    /// Dumps the symbols for the given package, using this workspace as the
    /// output directory.
    public static
    func dump(from package:PackageNode,
        include:IncludePaths = [],
        output:Workspace,
        triple:Triple,
        pretty:Bool = false) async throws -> Self
    {
        //  Note: the manifest root is the root we want; the repository root may
        //  be a relative path.
        let sources:[Sources] = try package.scan()
        var include:IncludePaths = include
            include.add(from: sources)
        return .init(cultures: try await Self.dump(from: sources,
                include: include,
                output: output,
                triple: triple,
                pretty: pretty),
            root: package.root)
    }

    private static
    func dump(from sources:[Sources],
        include:IncludePaths? = nil,
        output:Workspace,
        triple:Triple,
        pretty:Bool) async throws -> [Culture]
    {
        for sources:Sources in sources
        {
            let label:String

            switch sources.language
            {
            case .swift:
                label = "swift module, \(sources.module.type)"

            case let language:
                label = "\(language) module"
            }

            print("Dumping symbols for module '\(sources.module.id)' (\(label))")

            var arguments:[String] =
            [
                "symbolgraph-extract",

                "-module-name",                     "\(sources.module.id)",
                "-target",                          "\(triple)",
                "-minimum-access-level",            "internal",
                "-output-dir",                      "\(output.path)",
                "-emit-extension-block-symbols",
                "-include-spi-symbols",
                "-skip-inherited-docs",
            ]
            if  pretty
            {
                arguments.append("-pretty-print")
            }
            for include:FilePath in include?.paths ?? []
            {
                arguments.append("-I")
                arguments.append("\(include)")
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
        for part:Result<FilePath.Component, any Error> in output.path.directory
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

        return try sources.map
        {
            try .init(sources: $0,
                parts: parts[$0.module.id, default: []].map { output.path / $0 })
        }
    }
}

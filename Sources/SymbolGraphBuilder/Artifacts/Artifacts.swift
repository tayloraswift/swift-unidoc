import ModuleGraphs
import PackageGraphs
import PackageMetadata
import SymbolGraphParts
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
    /// Dumps the symbols for the given package, using this workspace as the
    /// output directory.
    public static
    func dump(from package:PackageNode,
        include:inout [FilePath],
        output:Workspace,
        triple:Triple,
        pretty:Bool = false) async throws -> Self
    {
        //  Note: the manifest root is the root we want; the repository root may
        //  be a relative path.
        let sources:PackageSources = try .init(scanning: package)
        return .init(cultures: try await Self.dump(modules: sources.modules,
                include: &include,
                output: output,
                triple: triple,
                pretty: pretty),
            root: package.root)
    }
    /// Dumps the symbols for the given targets, using this workspace as the
    /// output directory.
    public static
    func dump(modules:[ModuleDetails],
        output:Workspace,
        triple:Triple,
        pretty:Bool = false) async throws -> Self
    {
        var include:[FilePath] = []
        return .init(cultures: try await Self.dump(modules: modules.map(ModuleSources.init(_:)),
                include: &include,
                output: output,
                triple: triple,
                pretty: pretty))
    }

    private static
    func dump(modules:[ModuleSources],
        include:inout [FilePath],
        output:Workspace,
        triple:Triple,
        pretty:Bool) async throws -> [Culture]
    {
        for sources:ModuleSources in modules
        {
            include += sources.include

            let label:String

            switch sources.language
            {
            case .swift:
                label = "swift module, \(sources.module.type)"

            case let language:
                label = "\(language) module"
            }

            switch sources.module.id
            {
            case    "_CertificateInternals":    // unbuildable, from swift-certificates 1.0.0
                continue

            case let name:
                print("Dumping symbols for module '\(name)' (\(label))")
            }

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
            for include:FilePath in include
            {
                arguments.append("-I")
                arguments.append("\(include)")
            }

            try await SystemProcess.init(command: "swift", arguments: arguments)()
        }

        var parts:[ModuleIdentifier: [SymbolGraphPart.ID]] = [:]
        for part:Result<FilePath.Component, any Error> in output.path.directory
        {
            //  We don’t want to *parse* the JSON yet to discover the culture,
            //  because the JSON can be very large, and parsing JSON is very
            //  expensive (compared to parsing BSON). So we trust that the file
            //  name is correct and indicates what is contained within the file.
            if  let id:SymbolGraphPart.ID = .init("\(try part.get())")
            {
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
                        "XCTest",                       // site policy
                        "_Builtin_intrinsics",          // contains only one symbol, free(_:)
                        "_Builtin_stddef_max_align_t",  // contains only two symbols
                        "_InternalStaticMirror",        // unbuildable
                        "_InternalSwiftScan",           // unbuildable
                        "_SwiftConcurrencyShims",       // contains only two symbols
                        "std":                          // unbuildable
                    continue

                default:
                    parts[id.culture, default: []].append(id)
                }
            }
        }

        return modules.map
        {
            .init($0.module,
                articles: $0.articles,
                artifacts: output.path,
                parts: parts[$0.module.id, default: []])
        }
    }
}

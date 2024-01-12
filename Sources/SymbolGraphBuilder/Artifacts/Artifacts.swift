import PackageGraphs
import PackageMetadata
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

public
struct Artifacts
{
    let cultures:[Culture]
    var root:Symbol.FileBase?

    private
    init(cultures:[Culture], root:Symbol.FileBase? = nil)
    {
        self.cultures = cultures
        self.root = root
    }
}
extension Artifacts
{
    private
    init(dumping modules:[PackageBuild.Sources.Module],
        include:inout [FilePath],
        output:Workspace,
        triple:Triple,
        pretty:Bool) async throws
    {
        for sources:PackageBuild.Sources.Module in modules
        {
            let label:String
            if  case .toolchain? = sources.origin
            {
                label = "toolchain"
            }
            else
            {
                //  Only dump symbols for library targets.
                switch sources.module.type
                {
                case .binary:       include += sources.include
                case .executable:   continue
                case .regular:      include += sources.include
                case .macro:        include += sources.include
                case .plugin:       continue
                case .snippet:      continue
                case .system:       continue
                case .test:         continue
                }

                label = """
                \(sources.module.language?.description ?? "?"), \(sources.module.type)
                """
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
            for include:FilePath in include
            {
                arguments.append("-I")
                arguments.append("\(include)")
            }

            let null:FilePath = "/dev/null"
            try await null.open(.writeOnly)
            {
                let environment:SystemProcess.Environment = .inherit
                {
                    $0["SWIFT_BACKTRACE"] = "enable=no"
                }
                let extractor:SystemProcess = try .init(command: "swift",
                    arguments: arguments,
                    stderr: $0,
                    with: environment)

                do
                {
                    try await extractor()
                }
                catch SystemProcessError.exit(139, _)
                {
                    print("""
                    Failed to dump symbols for module '\(sources.module.id)' due to SIGSEGV \
                    from 'swift symbolgraph-extract'. This is a known bug in the Apple Swift \
                    compiler; see https://github.com/apple/swift/issues/68767.
                    """)

                    return
                }
            }
        }

        var parts:[Symbol.Module: [SymbolGraphPart.ID]] = [:]
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

        let cultures:[Culture] = modules.map
        {
            .init($0.module,
                articles: $0.articles,
                artifacts: output.path,
                parts: parts[$0.module.id, default: []])
        }

        self.init(cultures: cultures)
    }
}
extension Artifacts
{
    /// Dumps the symbols for the given package, using the `output` workspace as the
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
        let sources:PackageBuild.Sources = try .init(scanning: package)
        let root:Symbol.FileBase = package.root

        var package:Self = try await .init(dumping: sources.modules,
            include: &include,
            output: output,
            triple: triple,
            pretty: pretty)

        package.root = root

        return package
    }
    /// Dumps the symbols for the given targets, using the `output` workspace as the
    /// output directory.
    static
    func dump(modules:[PackageBuild.Sources.Module],
        output:Workspace,
        triple:Triple,
        pretty:Bool = false) async throws -> Self
    {
        var include:[FilePath] = []
        return try await .init(dumping: modules,
            include: &include,
            output: output,
            triple: triple,
            pretty: pretty)
    }
}

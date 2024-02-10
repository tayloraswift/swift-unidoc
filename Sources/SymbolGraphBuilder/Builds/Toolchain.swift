import JSON
import PackageGraphs
import PackageMetadata
import SemanticVersions
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

@frozen public
struct Toolchain
{
    public
    let version:AnyVersion
    public
    let tagname:String
    public
    let triple:Triple
    /// The `swift` command, which might be a path to a specific Swift toolchain, or just the
    /// string `"swift"`.
    private
    let swift:String

    private
    init(version:AnyVersion, tagname:String, triple:Triple, swift:String)
    {
        self.version = version
        self.tagname = tagname
        self.triple = triple
        self.swift = swift
    }
}
extension Toolchain
{
    private
    init(parsing splash:String, swift:String) throws
    {
        //  Splash should consist of two complete lines of the form
        //
        //  Swift version 5.8 (swift-5.8-RELEASE)
        //  Target: x86_64-unknown-linux-gnu
        let lines:[Substring] = splash.split(separator: "\n", omittingEmptySubsequences: false)
        //  if the final newline isn’t present, the output was clipped.
        guard lines.count == 3
        else
        {
            throw ToolchainError.malformedSplash
        }

        let toolchain:[Substring] = lines[0].split(separator: " ")
        let triple:[Substring] = lines[1].split(separator: " ")

        guard   toolchain.count >= 4,
                toolchain[0 ... 1] == ["Swift", "version"],
                triple.count == 2,
                triple[0] == "Target:"
        else
        {
            throw ToolchainError.malformedSplash
        }

        //  Swift version 5.8-dev (LLVM 07d14852a049e40, Swift 613b3223d9ec5f6)
        //  Target: x86_64-unknown-linux-gnu
        if  toolchain.count > 4
        {
            throw ToolchainError.developmentSnapshotNotSupported
        }

        let parenthesized:Substring = toolchain[3]

        guard parenthesized.startIndex < parenthesized.endIndex
        else
        {
            throw ToolchainError.malformedSplash
        }

        let i:String.Index = parenthesized.index(after: parenthesized.startIndex)
        let j:String.Index = parenthesized.index(before: parenthesized.endIndex)

        guard   i < j,
        case ("(", ")") = (parenthesized[parenthesized.startIndex], parenthesized[j])
        else
        {
            throw ToolchainError.malformedSplash
        }

        if  let triple:Triple = .init(triple[1])
        {

            self.init(
                version: .init(toolchain[2]),
                tagname: .init(parenthesized[i ..< j]),
                triple: triple,
                swift: swift)
        }
        else
        {
            throw ToolchainError.malformedTriple
        }
    }

    public static
    func detect(swift:String = "swift") async throws -> Self
    {
        let (readable, writable):(FileDescriptor, FileDescriptor) = try FileDescriptor.pipe()

        defer
        {
            try? writable.close()
            try? readable.close()
        }

        try await SystemProcess.init(command: swift, "--version", stdout: writable)()
        return try .init(parsing: try readable.read(buffering: 1024), swift: swift)
    }
}
extension Toolchain
{
    func platform() throws -> SymbolGraphMetadata.Platform
    {
        if      self.triple.os.starts(with: "linux")
        {
            return .linux
        }
        else if self.triple.os.starts(with: "ios")
        {
            return .iOS
        }
        else if self.triple.os.starts(with: "macos")
        {
            return .macOS
        }
        else if self.triple.os.starts(with: "tvos")
        {
            return .tvOS
        }
        else if self.triple.os.starts(with: "watchos")
        {
            return .watchOS
        }
        else if self.triple.os.starts(with: "windows")
        {
            return .windows
        }
        else
        {
            throw ToolchainError.unsupportedTriple(self.triple)
        }
    }
}

extension Toolchain
{
    func manifest(package:FilePath, json file:FilePath) async throws -> SPM.Manifest
    {
        //  The manifest can be very large, possibly larger than the 64 KB pipe buffer
        //  limit. So instead of getting the `dump-package` output from a pipe, we
        //  tell the subprocess to write it to a file, and read back the file afterwards.
        let json:JSON
        do
        {
            let utf8:[UInt8] = try await file.open(.readWrite,
                permissions: (.rw, .r, .r),
                options: [.create, .truncate])
            {
                let dump:SystemProcess = try .init(command: self.swift,
                    "package", "dump-package",
                    "--package-path", "\(package)",
                    stdout: $0)
                try await dump()
                return try $0.readAll()
            }

            json = .init(utf8: utf8)
        }
        catch let error
        {
            throw SPM.ManifestDumpError.init(underlying: error, root: package)
        }

        return try json.decode()
    }

    func resolve(package:FilePath, log:FilePath) async throws -> [SPM.DependencyPin]
    {
        print("Streaming 'swift package update' output to: \(log)")

        try await log.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            //  This command only prints to stderr, for some reason.
            try await SystemProcess.init(command: self.swift,
                "package",
                "update",
                "--package-path", "\(package)",
                stdout: nil,
                stderr: $0)()
        }

        do
        {
            let resolutions:SPM.DependencyResolutions = try .init(
                parsing: try (package / "Package.resolved").read())
            return resolutions.pins
        }
        catch is FileError
        {
            return []
        }
    }

    func build(
        package:FilePath,
        release:Bool = false,
        log:FilePath) async throws -> SPM.BuildDirectory
    {
        print("Streaming 'swift build' output to: \(log)")

        let scratch:SPM.BuildDirectory = .init(path: package / ".build.unidoc")

        try await log.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            try await SystemProcess.init(command: self.swift,
                "build",
                "--configuration", release ? "release" : "debug",
                "--package-path", "\(package)",
                "--scratch-path", "\(scratch.path)",
                stdout: $0)()
        }

        return scratch
    }
}
extension Toolchain
{
    /// Dumps the symbols for the given package, using the `output` workspace as the
    /// output directory.
    func dump(from package:PackageNode,
        snippetsDirectory:String,
        include:inout [FilePath],
        output:ArtifactsDirectory,
        triple:Triple,
        pretty:Bool = false) async throws -> Artifacts
    {
        let sources:SPM.PackageSources = try .init(scanning: package,
            snippetsDirectory: snippetsDirectory)

        let cultures:[Artifacts.Culture] = try await self.dump(
            modules: sources.cultures,
            include: &include,
            output: output,
            triple: triple,
            pretty: pretty)

        return .init(cultures: cultures, snippets: sources.snippets, root: package.root)
    }
    /// Dumps the symbols for the given targets, using the `output` workspace as the
    /// output directory.
    func dump(modules:[SPM.NominalSources],
        output:ArtifactsDirectory,
        triple:Triple,
        pretty:Bool = false) async throws -> Artifacts
    {
        var include:[FilePath] = []
        let cultures:[Artifacts.Culture] = try await self.dump(
            modules: modules,
            include: &include,
            output: output,
            triple: triple,
            pretty: pretty)

        return .init(cultures: cultures, snippets: [])
    }

    private
    func dump(modules:[SPM.NominalSources],
        include:inout [FilePath],
        output:ArtifactsDirectory,
        triple:Triple,
        pretty:Bool) async throws -> [Artifacts.Culture]
    {
        for sources:SPM.NominalSources in modules
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
                let extractor:SystemProcess = try .init(command: self.swift,
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

        return modules.map
        {
            .init($0.module,
                articles: $0.articles,
                artifacts: output.path,
                parts: parts[$0.module.id, default: []])
        }
    }
}
extension Toolchain
{
    @available(*, deprecated)
    public
    func generateDocs(for build:Toolchain.Build,
        pretty:Bool = false) async throws -> SymbolGraphObject<Void>
    {
        try await .init(building: build, with: self, pretty: pretty)
    }
    @available(*, deprecated)
    public
    func generateDocs(for build:SPM.Build,
        pretty:Bool = false) async throws -> SymbolGraphObject<Void>
    {
        try await .init(building: build, with: self, pretty: pretty)
    }
}

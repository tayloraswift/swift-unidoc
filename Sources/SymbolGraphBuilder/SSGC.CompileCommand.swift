import ArgumentParser
import BSON
import SymbolGraphs
import Symbols
import System_
import System_ArgumentParser

extension SSGC
{
    public
    struct CompileCommand:Decodable
    {
        @Option(
            name: [.customLong("workspace-name"), .customShort("w")],
            help: """
                A path to the workspace directory — \
                SSGC will create this workspace unless --workspace is set
                """)
        var workspaceName:FilePath.Directory = ".ssgc"

        @Option(
            name: [.customLong("workspace"), .customShort("W")],
            help: "A path to the workspace directory — SSGC will assume this workspace exists",
            completion: .directory)
        var workspacePath:FilePath.Directory? = nil

        @Option(
            name: [.customLong("status"), .customShort("P")],
            help: "A file descriptor index to emit status updates to")
        var status:Int32? = nil

        @Option(
            name: [.customLong("search-path"), .customShort("I")],
            help: """
            DEPRECATED: Where to look for a SwiftPM package to build, if building locally
            """,
            completion: .directory)
        var search:FilePath.Directory? = nil

        @Option(
            name: [.customLong("output"), .customShort("o")],
            help: "The path to write the compiled symbol graph to")
        var output:FilePath? = nil

        @Option(
            name: [.customLong("output-log"), .customShort("l")],
            help: "The path to write the log of the build process to")
        var outputLog:FilePath? = nil

        @Option(
            name: [.customLong("swift-toolchain"), .customShort("u")],
            help: "The path to a Swift toolchain directory, usually ending in 'usr'",
            completion: .directory)
        var swiftTools:FilePath.Directory?

        @Option(
            name: [.customLong("swiftpm-cache")],
            help: "The path to the SwiftPM cache directory to use",
            completion: .directory)
        var swiftCache:FilePath.Directory?

        @Option(
            name: [.customLong("sdk"), .customShort("k")],
            help: "The Apple SDK to use")
        var appleSDK:AppleSDK? = nil


        @Option(
            name: [.customLong("Xswiftc")],
            parsing: .unconditionalSingleValue,
            help: "Extra flags to pass to the Swift compiler")
        var swiftc:[String] = []

        @Option(
            name: [.customLong("Xcxx")],
            parsing: .unconditionalSingleValue,
            help: "Extra flags to pass to the C++ compiler")
        var cxx:[String] = []

        @Option(
            name: [.customLong("Xcc")],
            parsing: .unconditionalSingleValue,
            help: "Extra flags to pass to the C compiler")
        var cc:[String] = []


        @Option(
            name: [.customLong("ci")],
            help: "Run in CI mode under the specified validation level")
        var ci:ValidationBehavior? = nil

        @Option(
            name: [.customLong("project-path"), .customShort("p")],
            help: "Path to a local project to build",
            completion: .directory)
        var projectPath:FilePath.Directory?

        @Option(
            name: [.customLong("package-name"), .customShort("n")],
            help: """
                The symbolic name of the project to build — \
                this is not the name specified in the `Package.swift` manifest!
                """)
        var project:String?

        @Option(
            name: [.customLong("project-type"), .customShort("b")],
            help: "The type of project to build as")
        var type:ProjectType = .package

        @Option(
            name: [.customLong("project-repo"), .customShort("r")],
            help: "The URL of the git repository to clone")
        var repo:String? = nil

        @Option(
            name: [.customLong("ref"), .customShort("t")],
            help: "The git ref to check out")
        var ref:String? = nil


        @Flag(
            name: [.customLong("clean-artifacts")],
            help: """
                Clear the artifacts directory before building documentation — this should be \
                turned off if performing incremental builds, otherwise symbols will be missing \
                from generated documentation
                """)
        var cleanArtifacts:Bool = false

        @Flag(
            name: [.customLong("remove-build")],
            help: """
                Remove the Swift build directory (usually .build.ssgc) \
                after building documentation
                """)
        var removeBuild:Bool = false

        @Flag(
            name: [.customLong("remove-clone")],
            help: """
                Remove the cloned git repository after building documentation — \
                this has no effect for local builds, and will also not remove any cloned \
                repositories from the SwiftPM cache
                """)
        var removeClone:Bool = false

        //  The great irony of this flag is that adding the flag itself causes
        //  swift-argument-parser to crash with a bad pointer dereference. XD
        /*
        @Flag(
            name: [.customLong("recover-from-apple-bugs")],
            help: """
                Recover from known bugs in the Apple Swift compiler - this may result in \
                incomplete or broken documentation!
                """)
        var recoverFromAppleBugs:Bool = false
        */

        @Flag(
            name: [.customLong("pretty")],
            help: """
                Tell lib/SymbolGraphGen to pretty-print the JSON output, if possible
                """)
        var pretty:Bool = false

        public
        init()
        {
        }
    }
}
extension SSGC.CompileCommand
{
    public
    func launch() throws
    {
        guard
        let workspacePath:FilePath.Directory = self.workspacePath
        else
        {
            //  It would never make sense to write to a FIFO that we created ourselves, because
            //  no one else could be expected to read from it.
            let workspace:SSGC.Workspace = try .create(at: self.workspaceName)
            try self.launch(workspace: workspace, status: nil)
            return
        }

        let status:SSGC.StatusStream

        if  let file:Int32 = self.status
        {
            status = .init(file: .init(rawValue: file))
        }
        else
        {
            let workspace:SSGC.Workspace = .existing(at: workspacePath)
            try self.launch(workspace: workspace, status: nil)
            return
        }

        let workspace:SSGC.Workspace = .existing(at: workspacePath)
        do
        {
            try self.launch(workspace: workspace, status: status)
        }
        catch let error as SSGC.ManifestDumpError
        {
            try status.send(error.leaf
                ? .failedToReadManifest
                : .failedToReadManifestForDependency)
        }
        catch let error as SSGC.PackageBuildError
        {
            switch error
            {
            case .swift_package_update:         try status.send(.failedToResolveDependencies)
            case .swift_build:                  try status.send(.failedToBuild)
            case .swift_symbolgraph_extract:    try status.send(.failedToExtractSymbolGraph)
            }
        }
        catch let error as SSGC.DocumentationBuildError
        {
            //  We need to print the error here, otherwise it will be lost.
            print(error)

            switch error
            {
            case .scanning: try status.send(.failedToLoadSymbolGraph)
            case .loading:  try status.send(.failedToLoadSymbolGraph)
            case .linking:  try status.send(.failedToLinkSymbolGraph)
            }
        }
    }

    private
    func launch(workspace:SSGC.Workspace, status:SSGC.StatusStream?) throws
    {
        let validation:SSGC.ValidationBehavior = self.ci ?? .ignoreErrors
        if  let path:FilePath = self.outputLog
        {
            try path.open(.writeOnly,
                permissions: (.rw, .r, .r),
                options: [.create, .truncate])
            {
                try self.launch(workspace: workspace,
                    status: status,
                    logger: .init(validation: validation, file: $0))
            }
        }
        else
        {
            try self.launch(workspace: workspace,
                status: status,
                logger: .init(validation: validation, file: nil))
        }
    }

    private
    func launch(workspace:SSGC.Workspace,
        status:SSGC.StatusStream?,
        logger:SSGC.Logger) throws
    {
        let toolchain:SSGC.Toolchain = try .detect(appleSDK: self.appleSDK,
            paths: .init(swiftPM: self.swiftCache, usr: self.swiftTools),
            recoverFromAppleBugs: true, // self.recoverFromAppleBugs,
            pretty: self.pretty)

        let flags:SSGC.PackageBuild.Flags = .init(swift: self.swiftc, cxx: self.cxx, c: self.cc)
        let object:SymbolGraphObject<Void>

        if  let project:String = self.project,
            let repo:String = self.repo,
            let ref:String = self.ref
        {
            let symbol:Symbol.Package = .init(project)

            defer
            {
                let repoClone:FilePath.Directory = workspace.checkouts / "\(symbol)"

                if  self.removeClone
                {
                    try? repoClone.remove()
                }
            }

            let build:SSGC.PackageBuild = try .remote(project: symbol,
                from: repo,
                at: ref,
                as: self.type,
                in: workspace,
                flags: flags)

            defer
            {
                if  self.removeBuild
                {
                    try? build.scratch.location.remove()
                }
            }

            try status?.send(.didCloneRepository)

            object = try workspace.build(some: build,
                toolchain: toolchain,
                status: status,
                logger: logger,
                clean: self.cleanArtifacts)
        }
        else if case "swift"? = self.project
        {
            object = try workspace.build(some: SSGC.StandardLibraryBuild.swift,
                toolchain: toolchain,
                status: status,
                logger: logger,
                clean: self.cleanArtifacts)
        }
        else
        {
            let computedPath:FilePath.Directory

            if  let projectPath:FilePath.Directory = self.projectPath
            {
                computedPath = projectPath
            }
            else if
                let search:FilePath.Directory = self.search,
                let name:String = self.project
            {
                print("""
                    Warning: '--search-path' is deprecated, use '--project-path' with the
                    full path to the project root instead
                    """)

                computedPath = search / name
            }
            else
            {
                throw SSGC.ProjectPathRequiredError.init()
            }

            let build:SSGC.PackageBuild = .local(project: computedPath,
                using: ".build.ssgc",
                as: self.type,
                flags: flags)

            defer
            {
                if  self.removeBuild
                {
                    try? build.scratch.location.remove()
                }
            }

            object = try workspace.build(some: build,
                toolchain: toolchain,
                status: status,
                logger: logger,
                clean: self.cleanArtifacts)
        }

        let output:FilePath = self.output ?? workspace.location / "docs.bson"
        try output.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            let bson:BSON.Document = .init(encoding: object)
            try $0.writeAll(bson.bytes)
        }
    }
}

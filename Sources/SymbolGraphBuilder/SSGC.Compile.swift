import ArgumentParser
import BSON
import SymbolGraphs
import Symbols
import System_ArgumentParser
import System

extension SSGC
{
    public
    struct Compile:Decodable
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
            help: "Where to look for a SwiftPM package to build, if building locally",
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
            name: [.customLong("swift-runtime")],
            help: "The path to the Swift runtime directory, usually ending in /usr/lib",
            completion: .directory)
        var swiftRuntime:FilePath.Directory? = nil

        @Option(
            name: [.customLong("swiftpm-cache")],
            help: "The path to the SwiftPM cache directory to use",
            completion: .directory)
        var swiftCache:FilePath.Directory?

        @Option(
            name: [.customLong("swift"), .customShort("s")],
            help: "The path to the Swift toolchain",
            completion: .file(extensions: []))
        var swiftPath:FilePath? = nil

        @Option(
            name: [.customLong("sdk"), .customShort("k")],
            help: "The Swift SDK to use")
        var swiftSDK:AppleSDK? = nil

        @Option(
            name: [.customLong("package-name"), .customShort("n")],
            help: """
                The symbolic name of the project to build — \
                this is not the name specified in the `Package.swift` manifest!
                """)
        var name:Symbol.Package

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

        @Flag(
            name: [.customLong("pretty"), .customShort("p")],
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
extension SSGC.Compile
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
        let toolchain:SSGC.Toolchain = try .detect(swiftRuntime: self.swiftRuntime,
            swiftCache: self.swiftCache,
            swiftPath: self.swiftPath,
            swiftSDK: self.swiftSDK,
            pretty: self.pretty)

        let logger:SSGC.DocumentationLogger? = self.outputLog.map(SSGC.DocumentationLogger.init)
        let object:SymbolGraphObject<Void>

        if  self.name == .swift
        {
            object = try workspace.build(some: SSGC.SpecialBuild.swift,
                toolchain: toolchain,
                logger: logger,
                status: status)
        }
        else if
            let search:FilePath.Directory = self.search
        {
            let build:SSGC.PackageBuild = .local(project: self.name,
                among: search,
                as: self.type)

            defer
            {
                if  self.removeBuild
                {
                    try? (build.root / toolchain.scratch).remove()
                }
            }

            object = try workspace.build(some: build,
                toolchain: toolchain,
                logger: logger,
                status: status)
        }
        else if
            let repo:String = self.repo,
            let ref:String = self.ref
        {
            defer
            {
                let repoClone:FilePath.Directory = workspace.checkouts / "\(self.name)"

                if  self.removeClone
                {
                    try? repoClone.remove()
                }
                else if
                    self.removeBuild
                {
                    try? (repoClone / toolchain.scratch).remove()
                }
            }

            let build:SSGC.PackageBuild = try .remote(project: self.name,
                from: repo,
                at: ref,
                as: self.type,
                in: workspace)

            try status?.send(.didCloneRepository)

            object = try workspace.build(some: build,
                toolchain: toolchain,
                logger: logger,
                status: status)
        }
        else
        {
            throw SSGC.SearchPathRequiredError.init()
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

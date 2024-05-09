import ArgumentParsing
import BSON
import SymbolGraphs
import Symbols
import System

extension SSGC
{
    enum ScratchPolicy:String, Equatable
    {
        case keep
        case remove
    }
}
extension SSGC
{
    struct Main:Sendable
    {
        /// A path to the workspace directory. SSGC will **create** this workspace unless
        /// ``workspacePath`` is set.
        var workspaceName:FilePath
        /// A path to the workspace directory. SSGC will **assume** this workspace exists.
        var workspacePath:FilePath?
        /// A path to a FIFO that SSGC will use to communicate its status. If set, SSGC will
        /// block until something opens this FIFO for reading.
        var status:FilePath?
        var search:FilePath?

        var output:FilePath?
        var outputLog:FilePath?

        var swiftPath:FilePath?
        var swiftSDK:AppleSDK?

        var swiftCache:FilePath?

        var name:Symbol.Package?
        var repo:String?
        var ref:String?

        /// If true, SSGC will remove the Swift build directory (usually `.build.ssgc`) after
        /// it finishes building documentation.
        var removeBuild:Bool
        /// If true, SSGC will remove the cloned git repository after it finishes building
        /// documentation. This has no effect for local builds, and will also not remove any
        /// cloned repositories from the SwiftPM cache.
        var removeClone:Bool
        var pretty:Bool

        init()
        {
            self.workspaceName = ".ssgc"
            self.workspacePath = nil
            self.status = nil
            self.search = nil

            self.output = nil
            self.outputLog = nil

            self.swiftCache = nil
            self.swiftPath = nil
            self.swiftSDK = nil

            self.name = nil
            self.repo = nil
            self.ref = nil
            self.removeBuild = false
            self.removeClone = false
            self.pretty = false
        }
    }
}
extension SSGC.Main
{
    mutating
    func parse(arguments:consuming CommandLine.Arguments) throws
    {
        while let option:String = arguments.next()
        {
            switch option
            {
            case "--swiftpm-cache":
                self.swiftCache = .init(try arguments.next(for: option))

            case "--swift", "-s":
                self.swiftPath = .init(try arguments.next(for: option))

            case "--sdk", "-k":
                self.swiftSDK = try .init(arguments.next(for: option))

            case "--workspace-name", "-w":
                self.workspaceName = try .init(arguments.next(for: option))

            case "--workspace", "-W":
                self.workspacePath = try .init(arguments.next(for: option))

            case "--status", "-P":
                self.status = try .init(arguments.next(for: option))

            case "--search-path", "-I":
                self.search = .init(try arguments.next(for: option))

            case "--package-name", "-n":
                self.name = try .init(arguments.next(for: option))

            case "--package-repo", "-r":
                self.repo = try arguments.next(for: option)

            case "--ref", "-t":
                self.ref = try arguments.next(for: option)

            case "--output", "-o":
                self.output = try .init(arguments.next(for: option))

            case "--output-log", "-l":
                self.outputLog = try .init(arguments.next(for: option))

            case "--remove-build":
                self.removeBuild = true

            case "--remove-clone":
                self.removeClone = true

            case "--pretty", "-p":
                self.pretty = true

            case let option:
                throw CommandLine.ArgumentError.unknown(option)
            }
        }
    }

    func launch() throws
    {
        guard
        let workspacePath:FilePath = self.workspacePath
        else
        {
            //  It would never make sense to write to a FIFO that we created ourselves, because
            //  no one else could be expected to read from it.
            let workspace:SSGC.Workspace = try .create(at: self.workspaceName)
            try self.launch(workspace: workspace, status: nil)
            return
        }

        guard
        let status:FilePath = self.status
        else
        {
            let workspace:SSGC.Workspace = .existing(at: workspacePath)
            try self.launch(workspace: workspace, status: nil)
            return
        }

        try SSGC.StatusStream.write(to: status)
        {
            let workspace:SSGC.Workspace = .existing(at: workspacePath)
            do
            {
                try self.launch(workspace: workspace, status: $0)
                return .success
            }
            catch let error as SSGC.ManifestDumpError
            {
                return error.leaf ?
                    .failedToReadManifest :
                    .failedToReadManifestForDependency
            }
            catch let error as SSGC.PackageBuildError
            {
                switch error
                {
                case .swift_package_update:         return .failedToResolveDependencies
                case .swift_build:                  return .failedToBuild
                case .swift_symbolgraph_extract:    return .failedToExtractSymbolGraph
                }
            }
            catch let error as SSGC.DocumentationBuildError
            {
                switch error
                {
                case .scanning: return .failedToLoadSymbolGraph
                case .loading:  return .failedToLoadSymbolGraph
                case .linking:  return .failedToLinkSymbolGraph
                }
            }
        }
    }

    private
    func launch(workspace:SSGC.Workspace, status:SSGC.StatusStream?) throws
    {
        guard
        let package:Symbol.Package = self.name
        else
        {
            throw CommandLine.ArgumentError.missing("--package-name")
        }

        let toolchain:SSGC.Toolchain = try .detect(swiftCache: self.swiftCache,
            swiftPath: self.swiftPath,
            swiftSDK: self.swiftSDK,
            pretty: self.pretty)

        let logger:SSGC.DocumentationLogger? = self.outputLog.map(SSGC.DocumentationLogger.init)
        let object:SymbolGraphObject<Void>

        if  package == .swift
        {
            object = try workspace.build(some: SSGC.SpecialBuild.swift,
                toolchain: toolchain,
                logger: logger,
                status: status)
        }
        else if
            let search:FilePath = self.search
        {
            let build:SSGC.PackageBuild = .local(package: package, from: search)

            defer
            {
                if  self.removeBuild
                {
                    try? (build.root / toolchain.scratch).directory.remove()
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
                let repoClone:FilePath = workspace.checkouts / "\(package)"

                if  self.removeClone
                {
                    try? repoClone.directory.remove()
                }
                else if
                    self.removeBuild
                {
                    try? (repoClone / toolchain.scratch).directory.remove()
                }
            }

            let build:SSGC.PackageBuild = try .remote(
                package: package,
                from: repo,
                at: ref,
                in: workspace)

            try status?.send(.didCloneRepository)

            object = try workspace.build(some: build,
                toolchain: toolchain,
                logger: logger,
                status: status)
        }
        else
        {
            throw CommandLine.ArgumentError.missing("--search-path")
        }

        let output:FilePath = self.output ?? workspace.path / "docs.bson"
        try output.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            let bson:BSON.Document = .init(encoding: object)
            try $0.writeAll(bson.bytes)
        }
    }
}

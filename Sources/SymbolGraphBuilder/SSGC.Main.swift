import ArgumentParsing
import BSON
import SymbolGraphs
import Symbols
import System

extension SSGC
{
    struct Main:Sendable
    {
        var workspaceName:FilePath.Directory
        var workspacePath:FilePath.Directory?

        var status:FilePath?
        var search:FilePath.Directory?

        var output:FilePath?
        var outputLog:FilePath?

        var swiftRuntime:FilePath.Directory?
        var swiftCache:FilePath.Directory?
        var swiftPath:FilePath?
        var swiftSDK:AppleSDK?

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

            self.swiftRuntime = nil
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
        while let word:String = arguments.next()
        {
            guard
            let option:Option = .init(word)
            else
            {
                throw CommandLine.ArgumentError.unknown(word)
            }

            switch option
            {
            case .swiftpm_cache:    self.swiftCache = .init(try arguments.next(for: word))
            case .swift_runtime:    self.swiftRuntime = .init(try arguments.next(for: word))
            case .swift:            self.swiftPath = .init(try arguments.next(for: word))
            case .sdk:              self.swiftSDK = .init(try arguments.next(for: word))
            case .workspace_name:   self.workspaceName = .init(try arguments.next(for: word))
            case .workspace:        self.workspacePath = .init(try arguments.next(for: word))
            case .status:           self.status = .init(try arguments.next(for: word))
            case .search_path:      self.search = .init(try arguments.next(for: word))
            case .package_name:     self.name = .init(try arguments.next(for: word))
            case .package_repo:     self.repo = try arguments.next(for: word)
            case .ref:              self.ref = try arguments.next(for: word)
            case .output:           self.output = .init(try  arguments.next(for: word))
            case .output_log:       self.outputLog = .init(try arguments.next(for: word))
            case .remove_build:     self.removeBuild = true
            case .remove_clone:     self.removeClone = true
            case .pretty:           self.pretty = true
            }
        }
    }

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
            catch let error
            {
                print(error)
                return .failedForUnknownReason
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

        let toolchain:SSGC.Toolchain = try .detect(swiftRuntime: self.swiftRuntime,
            swiftCache: self.swiftCache,
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
            let search:FilePath.Directory = self.search
        {
            let build:SSGC.PackageBuild = .local(package: package, among: search)

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
                let repoClone:FilePath.Directory = workspace.checkouts / "\(package)"

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

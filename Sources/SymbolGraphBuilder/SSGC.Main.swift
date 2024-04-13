import ArgumentParsing
import BSON
import SymbolGraphs
import Symbols
import System

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

        var swiftPath:String
        var swiftSDK:AppleSDK?

        var name:Symbol.Package?
        var repo:String?
        var tag:String?
        var log:LogMode
        var pretty:Bool

        init()
        {
            self.workspaceName = ".ssgc"
            self.workspacePath = nil
            self.status = nil
            self.search = nil

            self.swiftPath = "swift"
            self.swiftSDK = nil

            self.name = nil
            self.repo = nil
            self.tag = nil
            self.log = .toConsole
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
            case "--swift", "-s":
                self.swiftPath = try arguments.next(for: option)

            case "--workspace-name", "-w":
                self.workspaceName = try .init(arguments.next(for: option))

            case "--workspace", "-W":
                self.workspacePath = try .init(arguments.next(for: option))

            case "--status", "-P":
                self.status = try .init(arguments.next(for: option))

            case "--search-path", "-I":
                self.search = .init(try arguments.next(for: option))

            case "--sdk", "-k":
                self.swiftSDK = try .init(arguments.next(for: option))

            case "--package-name", "-n":
                self.name = try .init(arguments.next(for: option))

            case "--package-repo", "-r":
                self.repo = try arguments.next(for: option)

            case "--tag", "-t":
                self.tag = try arguments.next(for: option)

            case "--log-to-file", "-l":
                self.log = .toFile

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

        let workspace:SSGC.Workspace = .existing(at: workspacePath)
        try workspace.status.open(.writeOnly,
            permissions: (.rw, .r, .r))
        {
            let status:SSGC.StatusUpdate
            do
            {
                try self.launch(workspace: workspace, status: $0)
                status = .success
            }
            catch let error as SSGC.ManifestDumpError
            {
                status = error.leaf ?
                    .failedToReadManifest :
                    .failedToReadManifestForDependency
            }
            catch let error as SSGC.PackageBuildError
            {
                switch error
                {
                case .swift_package_update:         status = .failedToResolveDependencies
                case .swift_build:                  status = .failedToBuild
                case .swift_symbolgraph_extract:    status = .failedToExtractSymbolGraph
                }
            }
            catch let error as SSGC.DocumentationBuildError
            {
                switch error
                {
                case .loading:  status = .failedToLoadSymbolGraph
                case .linking:  status = .failedToLinkSymbolGraph
                }
            }

            try $0.writeAll([status.rawValue])
        }
    }

    private
    func launch(workspace:SSGC.Workspace, status _:FileDescriptor?) throws
    {
        guard
        let package:Symbol.Package = self.name
        else
        {
            throw CommandLine.ArgumentError.missing("--package-name")
        }

        let toolchain:SSGC.Toolchain = try .detect(
            swiftPath: self.swiftPath,
            swiftSDK: self.swiftSDK,
            pretty: self.pretty)


        let log:FilePath.Component?

        switch self.log
        {
        case .toConsole:    log = nil
        case .toFile:       log = "docs.log"
        }

        let object:SymbolGraphObject<Void>

        if  package == .swift
        {
            object = try workspace.build(special: .swift, with: toolchain, log: log)
        }
        else if
            let repo:String = self.repo,
            let tag:String = self.tag
        {
            let build:SSGC.PackageBuild = try .remote(
                package: package,
                from: repo,
                at: tag,
                in: workspace)

            object = try workspace.build(package: build, with: toolchain, log: log)
        }
        else if
            let search:FilePath = self.search
        {
            let build:SSGC.PackageBuild = try .local(package: package, from: search)

            object = try workspace.build(package: build, with: toolchain, log: log)
        }
        else
        {
            throw CommandLine.ArgumentError.missing("--search-path")
        }

        try (workspace.artifacts / "docs.bson").open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            let bson:BSON.Document = .init(encoding: object)
            try $0.writeAll(bson.bytes)
        }
    }
}

import ArgumentParser
import BSON
import SymbolGraphs
import Symbols
import SystemIO
import System_ArgumentParser

extension SSGC
{
    /// The `slave` command is used by a driver process to monitor and collect the output of a
    /// documentation build. It has many assumptions about the file descriptors it expects to
    /// have been set up for it, and is not intended to be run directly by a user.
    public
    struct SlaveCommand:Decodable
    {
        @Argument(help: "The Git repository URL to clone")
        var repo:String

        @Argument(help: "The Git ref to check out")
        var ref:String

        @OptionGroup(title: "Compilation Options")
        var build:BuildOptions

        @Option(
            name: [.customLong("workspace"), .customShort("W")],
            help: "A path to the workspace directory",
            completion: .directory)
        var workspace:FilePath.Directory = "unidoc"

        @Option(
            name: [.customLong("status"), .customShort("P")],
            help: "A file descriptor index to emit status updates to")
        var status:Int32? = nil


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

        public
        init()
        {
        }
    }
}
extension SSGC.SlaveCommand:AsyncParsableCommand
{
    public
    static let configuration:CommandConfiguration = .init(
        commandName: "slave",
        shouldDisplay: false)

    public
    func run() throws
    {
        let status:SSGC.StatusStream

        if  let file:Int32 = self.status
        {
            status = .init(file: .init(rawValue: file))
        }
        else
        {
            try self.launch(status: nil)
            return
        }

        do
        {
            try self.launch(status: status)
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
    func launch(status:SSGC.StatusStream?) throws
    {
        let validation:SSGC.ValidationBehavior = self.build.ci ?? .ignoreErrors

        guard
        let path:FilePath = self.build.outputLog
        else
        {
            try self.launch(status: status, logger: .init(validation: validation, file: nil))
            return
        }

        try path.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            try self.launch(status: status, logger: .init(validation: validation, file: $0))
        }
    }

    private
    func launch(status:SSGC.StatusStream?, logger:SSGC.Logger) throws
    {
        let workspace:SSGC.Workspace = try .create(at: self.workspace)

        let projectName:String
        if  let project:String = self.build.projectName
        {
            projectName = project
        }
        else if
            let slash:String.Index = self.repo.lastIndex(of: "/")
        {
            let start:String.Index = self.repo.index(after: slash)
            projectName = String.init(self.repo[start...].prefix { $0 != "." })
        }
        else
        {
            throw SSGC.ProjectNameRequiredError.init()
        }

        if  projectName.isEmpty
        {
            throw SSGC.ProjectNameRequiredError.init()
        }

        let object:SymbolGraphObject<Void>
        do
        {
            let toolchain:SSGC.Toolchain = try self.build.toolchain
            let symbol:Symbol.Package = .init(projectName)

            defer
            {
                let repoClone:FilePath.Directory = workspace.checkouts / "\(symbol)"

                if  self.removeClone
                {
                    try? repoClone.remove()
                }
            }

            let package:SSGC.PackageBuild = try .remote(project: symbol,
                from: self.repo,
                at: self.ref,
                as: self.build.projectType,
                in: workspace,
                flags: self.build.flags)

            defer
            {
                if  self.removeBuild
                {
                    try? package.scratch.location.remove()
                }
            }

            try status?.send(.didCloneRepository)

            object = try package.build(
                toolchain: toolchain,
                define: self.build.defines,
                status: status,
                logger: logger,
                clean: self.cleanArtifacts)
        }

        let output:FilePath = self.build.output ?? workspace.location / "docs.bson"
        try output.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            let bson:BSON.Document = .init(encoding: object)
            try $0.writeAll(bson.bytes)
        }
    }
}

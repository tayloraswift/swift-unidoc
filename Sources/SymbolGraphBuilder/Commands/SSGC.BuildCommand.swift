import ArgumentParser
import BSON
import SymbolGraphs
import System_ArgumentParser
import SystemIO

extension SSGC
{
    public
    struct BuildCommand:Decodable
    {
        @OptionGroup(title: "Compilation Options")
        var build:BuildOptions

        @Option(
            name: [.customLong("project-path"), .customShort("p")],
            help: "Path to a local project to build",
            completion: .directory)
        var projectPath:FilePath.Directory = "."


        @Flag(
            name: [.customLong("clean-artifacts")],
            help: """
                Clear the artifacts directory before building documentation — this should be \
                turned off if performing incremental builds, otherwise symbols will be missing \
                from generated documentation
                """)
        var cleanArtifacts:Bool = false

        public
        init()
        {
        }
    }
}
extension SSGC.BuildCommand:AsyncParsableCommand
{
    public
    static let configuration:CommandConfiguration = .init(commandName: "build")

    public
    func run() throws
    {
        let validation:SSGC.ValidationBehavior = self.build.ci ?? .ignoreErrors

        guard
        let path:FilePath = self.build.outputLog
        else
        {
            try self.launch(logger: .init(validation: validation, file: nil))
            return
        }

        try path.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            try self.launch( logger: .init(validation: validation, file: $0))
        }
    }

    private
    func launch(logger:SSGC.Logger) throws
    {
        let toolchain:SSGC.Toolchain = try self.build.toolchain
        let object:SymbolGraphObject<Void>

        if  case "swift"? = self.build.projectName
        {
            let temporary:FilePath.Directory = self.projectPath / ".swift.ssgc"
            try temporary.create()
            defer { try? temporary.remove() }

            let stdlib:SSGC.StandardLibraryBuild = .init(cache: temporary)
            try stdlib.cache.create(clean: self.cleanArtifacts)
            object = try stdlib.build(
                toolchain: toolchain,
                define: self.build.defines,
                status: nil,
                logger: logger,
                clean: self.cleanArtifacts)
        }
        else
        {
            let package:SSGC.PackageBuild = .local(project: self.projectPath,
                using: ".build.ssgc",
                as: self.build.projectType,
                flags: self.build.flags)

            object = try package.build(
                toolchain: toolchain,
                define: self.build.defines,
                status: nil,
                logger: logger,
                clean: self.cleanArtifacts)
        }

        let output:FilePath = self.build.output ?? "docs.bson"
        try output.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            let bson:BSON.Document = .init(encoding: object)
            try $0.writeAll(bson.bytes)
        }
    }
}

import ArgumentParser
import SymbolGraphCompiler

@main
struct Main
{
    @Flag(name: [.customLong("version")], help: "Print version information and exit")
    var version:Bool = false
}
extension Main:AsyncParsableCommand
{
    static let configuration:CommandConfiguration = .init(commandName: "unidoc",
        subcommands: [
            SSGC.CompileCommand.self,
            SSGC.BuildCommand.self,
            SSGC.SlaveCommand.self,
            Unidoc.InitCommand.self,
            Unidoc.LocalCommand.self,
            Unidoc.PreviewCommand.self,
            Unidoc.ListAssetsCommand.self,
        ])

    func run() async throws
    {
        if  self.version
        {
            print(Unidoc.version)
        }
    }
}

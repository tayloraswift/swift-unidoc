import ArgumentParser
import SymbolGraphCompiler

@main
struct Main:AsyncParsableCommand
{
    static let configuration:CommandConfiguration = .init(subcommands: [
            SSGC.CompileCommand.self,
            Unidoc.InitCommand.self,
            Unidoc.LocalCommand.self,
            Unidoc.PreviewCommand.self,
            Unidoc.ListAssetsCommand.self,
        ])
}

import ArgumentParser
import SymbolGraphCompiler

@main
struct Main:AsyncParsableCommand
{
    static let configuration:CommandConfiguration = .init(subcommands: [
            SSGC.Compile.self,
            Local.self
        ])
}

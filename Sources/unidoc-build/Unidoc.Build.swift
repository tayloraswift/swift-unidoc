import ArgumentParser
import SymbolGraphCompiler

extension Unidoc
{
    @main
    struct Build:AsyncParsableCommand
    {
        static let configuration:CommandConfiguration = .init(subcommands: [
                SSGC.Main.self,
                Local.self
            ])
    }
}

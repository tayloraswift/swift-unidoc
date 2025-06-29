import ArgumentParser
import SymbolGraphBuilder

@main
struct Main:AsyncParsableCommand
{
    static var configuration:CommandConfiguration
    {
        .init(commandName: "ssgc",
            subcommands: [
                SSGC.BuildCommand.self,
                SSGC.SlaveCommand.self,
            ])
    }
}

import ArgumentParser
import SymbolGraphBuilder

@main
struct Main:ParsableCommand
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


import ArgumentParser
import SymbolGraphBuilder

@main struct Main: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        .init(
            commandName: "unidocd",
            subcommands: [UpCommand.self, SSGC.BuildCommand.self, SSGC.SlaveCommand.self]
        )
    }
}

import ArgumentParser
import SymbolGraphBuilder

extension SSGC.Compile:AsyncParsableCommand
{
    public
    static let configuration:CommandConfiguration = .init(commandName: "compile")

    /// For inexplicable reasons, this needs to conform to `AsyncParsableCommand` and provide
    /// an explicitly `async` ``run`` witness, otherwise the default implementation kicks in.
    public
    func run() async throws { try self.launch() }
}

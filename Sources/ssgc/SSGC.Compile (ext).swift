import ArgumentParser
import SymbolGraphBuilder

@main
extension SSGC.Compile:ParsableCommand
{
    public
    func run() throws
    {
        try self.launch()
    }
}

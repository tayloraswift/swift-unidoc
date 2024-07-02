import ArgumentParser
import SymbolGraphBuilder

@main
extension SSGC.Main:ParsableCommand
{
    public
    func run() throws
    {
        try self.launch()
    }
}

import ArgumentParser
import SymbolGraphBuilder

@main
extension SSGC.CompileCommand:ParsableCommand
{
    public
    func run() throws
    {
        try self.launch()
    }
}

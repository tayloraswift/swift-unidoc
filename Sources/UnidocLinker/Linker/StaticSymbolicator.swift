import ModuleGraphs
import SymbolGraphs
import Symbols
import UnidocDiagnostics

public
struct StaticSymbolicator:Sendable
{
    public
    let demangler:Demangler?
    public
    let root:Repository.Root?

    private
    let graph:SymbolGraph

    public
    init(graph:SymbolGraph, root:Repository.Root?)
    {
        self.demangler = .init()
        self.root = root

        self.graph = graph
    }
}
extension StaticSymbolicator:Symbolicator
{
    public
    func loadDeclSymbol(_ scalar:Int32) -> Symbol.Decl?
    {
        self.graph.decls[scalar] as Symbol.Decl?
    }
    public
    func loadFileSymbol(_ scalar:Int32) -> Symbol.File?
    {
        self.graph.files[scalar] as Symbol.File?
    }
}
extension StaticSymbolicator
{
    public
    func emit(_ errors:[any StaticLinkerError], colors:TerminalColors = .disabled)
    {
        for error:any StaticLinkerError in errors
        {
            for diagnostic:Diagnostic in error.symbolicated(with: self)
            {
                print(diagnostic.description(colors: colors), terminator: "\n\n")
            }
        }
    }
}

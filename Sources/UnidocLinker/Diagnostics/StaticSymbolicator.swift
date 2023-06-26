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
    func loadScalarSymbol(_ address:Int32) -> ScalarSymbol?
    {
        self.graph.symbols[address] as ScalarSymbol?
    }
    public
    func loadFileSymbol(_ address:Int32) -> FileSymbol?
    {
        self.graph.files[address]
    }
}
extension StaticSymbolicator
{
    public
    func emit(diagnoses:[any StaticDiagnosis], colors:TerminalColors = .disabled)
    {
        for diagnosis:any StaticDiagnosis in diagnoses
        {
            for diagnostic:Diagnostic in diagnosis.symbolicated(with: self)
            {
                print(diagnostic.description(colors: colors), terminator: "\n\n")
            }
        }
    }
}

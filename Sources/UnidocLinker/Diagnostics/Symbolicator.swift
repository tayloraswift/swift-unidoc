import ModuleGraphs
import SymbolGraphs
import Symbols

public
struct Symbolicator:Sendable
{
    private
    let demangler:Demangler?

    private
    let graph:SymbolGraph
    private
    let root:Repository.Root?

    public
    init(graph:SymbolGraph, root:Repository.Root?)
    {
        self.demangler = .init()
        self.graph = graph
        self.root = root
    }
}
extension Symbolicator
{
    func callAsFunction(demangling address:Int32) -> String
    {
        let symbol:ScalarSymbol = self[declaration: address]
        if  let demangled:String = self.demangler?.demangle(symbol)
        {
            return demangled
        }
        else
        {
            print("warning: demangling not supported on this platform!")
            return symbol.rawValue
        }

    }
}
extension Symbolicator
{
    subscript(declaration address:Int32) -> ScalarSymbol
    {
        self.graph.symbols[address]
    }
    subscript(file address:Int32) -> String
    {
        self.root.map { $0 / self.graph.files[address] } ?? "\(self.graph.files[address])"
    }
}
extension Symbolicator
{
    public
    func emit(diagnoses:[any StaticDiagnosis], colors:TerminalColors = .disabled)
    {
        for diagnosis:any StaticDiagnosis in diagnoses
        {
            for diagnostic:StaticDiagnostic in diagnosis.symbolicated(with: self)
            {
                print(diagnostic.description(colors: colors), terminator: "\n\n")
            }
        }
    }
}

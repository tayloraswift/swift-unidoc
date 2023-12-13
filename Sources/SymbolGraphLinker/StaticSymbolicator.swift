import SymbolGraphs
import Symbols
import UnidocDiagnostics

@_spi(testable) public
struct StaticSymbolicator:Sendable
{
    public
    let demangler:Demangler?
    public
    let root:Symbol.FileBase?

    private
    let graph:SymbolGraph

    init(graph:SymbolGraph, root:Symbol.FileBase?)
    {
        self.demangler = .init()
        self.root = root

        self.graph = graph
    }
}
@_spi(testable)
extension StaticSymbolicator:DiagnosticSymbolicator
{
    public
    subscript(article scalar:Int32) -> Symbol.Article?
    {
        SymbolGraph.Plane.article.contains(scalar)
            ? self.graph.articles.symbols[scalar]
            : nil
    }

    public
    subscript(decl scalar:Int32) -> Symbol.Decl?
    {
        SymbolGraph.Plane.decl.contains(scalar)
            ? self.graph.decls.symbols[scalar]
            : nil
    }

    public
    subscript(file scalar:Int32) -> Symbol.File?
    {
        SymbolGraph.Plane.file.contains(scalar)
            ? self.graph.files[scalar]
            : nil
    }
}

import SymbolGraphs
import Symbols
import Unidoc
import UnidocDiagnostics

public
struct StaticSymbolicator:Sendable
{
    public
    let demangler:Demangler?
    public
    let root:Symbol.FileBase?

    private
    let graph:SymbolGraph

    public
    init(graph:SymbolGraph, root:Symbol.FileBase?)
    {
        self.demangler = .init()
        self.root = root

        self.graph = graph
    }
}
extension StaticSymbolicator:DiagnosticSymbolicator
{
    public
    subscript(article scalar:Int32) -> Symbol.Article?
    {
        UnidocPlane.article.contains(scalar)
            ? self.graph.articles.symbols[scalar]
            : nil
    }

    public
    subscript(decl scalar:Int32) -> Symbol.Decl?
    {
        UnidocPlane.decl.contains(scalar)
            ? self.graph.decls.symbols[scalar]
            : nil
    }

    public
    subscript(file scalar:Int32) -> Symbol.File?
    {
        UnidocPlane.file.contains(scalar)
            ? self.graph.files[scalar]
            : nil
    }
}

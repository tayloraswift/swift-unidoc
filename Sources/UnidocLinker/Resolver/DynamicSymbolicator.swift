import SymbolGraphs
import Symbols
import UnidocDiagnostics

@usableFromInline final
class DynamicSymbolicator
{
    @usableFromInline
    let demangler:Demangler?
    @usableFromInline
    let root:Symbol.FileBase?

    private
    let context:DynamicLinker

    init(context:consuming DynamicLinker, root:Symbol.FileBase?)
    {
        self.demangler = .init()
        self.root = root

        self.context = context
    }
}
extension DynamicSymbolicator:DiagnosticSymbolicator
{
    @usableFromInline
    subscript(article scalar:Unidoc.Scalar) -> Symbol.Article?
    {
        SymbolGraph.Plane.article.contains(scalar.citizen)
            ? self.context[scalar.package]?.articles.symbols[scalar.citizen]
            : nil
    }

    @usableFromInline
    subscript(decl scalar:Unidoc.Scalar) -> Symbol.Decl?
    {
        SymbolGraph.Plane.decl.contains(scalar.citizen)
            ? self.context[scalar.package]?.decls.symbols[scalar.citizen]
            : nil
    }

    @usableFromInline
    subscript(file scalar:Unidoc.Scalar) -> Symbol.File?
    {
        SymbolGraph.Plane.file.contains(scalar.citizen)
            ? self.context[scalar.package]?.files[scalar.citizen]
            : nil
    }
}

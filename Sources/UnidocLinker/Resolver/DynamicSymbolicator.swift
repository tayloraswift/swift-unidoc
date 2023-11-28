import Symbols
import Unidoc
import UnidocDiagnostics

@frozen public
struct DynamicSymbolicator
{
    public
    let demangler:Demangler?
    public
    let root:Symbol.FileBase?

    @usableFromInline internal
    let context:DynamicContext

    @inlinable public
    init(context:DynamicContext, root:Symbol.FileBase?)
    {
        self.demangler = .init()
        self.root = root

        self.context = context
    }
}
extension DynamicSymbolicator:DiagnosticSymbolicator
{
    public
    subscript(article scalar:Unidoc.Scalar) -> Symbol.Article?
    {
        UnidocPlane.article.contains(scalar.citizen)
            ? self.context[scalar.package]?.articles.symbols[scalar.citizen]
            : nil
    }

    public
    subscript(decl scalar:Unidoc.Scalar) -> Symbol.Decl?
    {
        UnidocPlane.decl.contains(scalar.citizen)
            ? self.context[scalar.package]?.decls.symbols[scalar.citizen]
            : nil
    }

    public
    subscript(file scalar:Unidoc.Scalar) -> Symbol.File?
    {
        UnidocPlane.file.contains(scalar.citizen)
            ? self.context[scalar.package]?.files[scalar.citizen]
            : nil
    }
}

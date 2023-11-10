import ModuleGraphs
import Symbols
import Unidoc
import UnidocDiagnostics

@frozen public
struct DynamicSymbolicator:Sendable
{
    public
    let demangler:Demangler?
    public
    let root:Repository.Root?

    @usableFromInline internal
    let context:DynamicContext

    @inlinable public
    init(context:DynamicContext, root:Repository.Root?)
    {
        self.demangler = .init()
        self.root = root

        self.context = context
    }
}
extension DynamicSymbolicator:DiagnosticSymbolicator
{
    public
    func loadDeclSymbol(_ scalar:Unidoc.Scalar) -> Symbol.Decl?
    {
        self.context[scalar.package]?.decls.symbols[scalar.citizen]
    }
    public
    func loadFileSymbol(_ scalar:Unidoc.Scalar) -> Symbol.File?
    {
        self.context[scalar.package]?.files[scalar.citizen]
    }
}

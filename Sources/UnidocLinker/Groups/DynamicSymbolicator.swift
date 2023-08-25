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
extension DynamicSymbolicator:Symbolicator
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
extension DynamicSymbolicator
{
    public
    func emit(_ errors:[any DynamicLinkerError], colors:TerminalColors = .disabled)
    {
        for error:any DynamicLinkerError in errors
        {
            for diagnostic:Diagnostic in error.symbolicated(with: self)
            {
                print(diagnostic.description(colors: colors), terminator: "\n\n")
            }
        }
    }
}

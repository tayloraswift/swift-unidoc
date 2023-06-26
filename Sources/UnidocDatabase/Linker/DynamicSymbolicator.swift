import ModuleGraphs
import SymbolGraphs
import Symbols
import UnidocDiagnostics

struct DynamicSymbolicator:Sendable
{
    public
    let demangler:Demangler?
    public
    let root:Repository.Root?

    private
    let context:DynamicContext

    init(context:DynamicContext, root:Repository.Root?)
    {
        self.demangler = .init()
        self.root = root

        self.context = context
    }
}
extension DynamicSymbolicator:Symbolicator
{
    func loadScalarSymbol(_ scalar:Scalar96) -> ScalarSymbol?
    {
        self.context[scalar.package]?.symbols[scalar]
    }
    func loadFileSymbol(_ scalar:Scalar96) -> FileSymbol?
    {
        self.context[scalar.package]?.files[scalar]
    }
}
extension DynamicSymbolicator
{
    func emit(diagnoses:[any DynamicDiagnosis], colors:TerminalColors = .disabled)
    {
        for diagnosis:any DynamicDiagnosis in diagnoses
        {
            for diagnostic:Diagnostic in diagnosis.symbolicated(with: self)
            {
                print(diagnostic.description(colors: colors), terminator: "\n\n")
            }
        }
    }
}

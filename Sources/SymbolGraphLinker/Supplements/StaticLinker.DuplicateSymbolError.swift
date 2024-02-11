import Sources
import UnidocDiagnostics

extension StaticLinker
{
    enum DuplicateSymbolError:Equatable, Error, Sendable
    {
        case article(name:String)
    }
}
extension StaticLinker.DuplicateSymbolError:Diagnostic
{
    typealias Symbolicator = StaticSymbolicator

    static
    func += (output:inout DiagnosticOutput<StaticSymbolicator>, self:Self)
    {
        switch self
        {
        case .article(let name):
            output[.warning] = """
            markdown article cannot have the same mangled name ('\(name)') as another \
            article in the same module
            """
        }
    }
}

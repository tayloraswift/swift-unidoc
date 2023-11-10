import Sources
import UnidocDiagnostics

extension StaticLinker
{
    @frozen public
    enum DuplicateSymbolError:Equatable, Error, Sendable
    {
        case article(id:String)
    }
}
extension StaticLinker.DuplicateSymbolError:Diagnostic
{
    public
    typealias Symbolicator = StaticSymbolicator

    @inlinable public static
    func += (output:inout DiagnosticOutput<StaticSymbolicator>, self:Self)
    {
        switch self
        {
        case .article(let id):
            output[.warning] = """
            markdown article cannot have the same mangled name ('\(id)') as another \
            article in the same module
            """
        }
    }
}

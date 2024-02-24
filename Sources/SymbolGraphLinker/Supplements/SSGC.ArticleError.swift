import Sources
import SourceDiagnostics

extension SSGC
{
    enum ArticleError:Equatable, Error, Sendable
    {
        case duplicated(name:String)
    }
}
extension SSGC.ArticleError:Diagnostic
{
    typealias Symbolicator = SSGC.Symbolicator

    static
    func += (output:inout DiagnosticOutput<SSGC.Symbolicator>, self:Self)
    {
        switch self
        {
        case .duplicated(name: let name):
            output[.warning] = """
            markdown article cannot have the same mangled name ('\(name)') as another \
            article in the same module
            """
        }
    }
}

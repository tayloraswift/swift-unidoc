import Sources
import UnidocDiagnostics

extension StaticLinker
{
    enum SupplementError:Error, Equatable, Sendable
    {
        case implicitConcatenation
        case multiple
        case untitled
    }
}
extension StaticLinker.SupplementError:Diagnostic
{
    typealias Symbolicator = StaticSymbolicator

    static
    func += (output:inout DiagnosticOutput<StaticSymbolicator>, self:Self)
    {
        switch self
        {
        case .implicitConcatenation:
            output[.warning] = """
            markdown supplement extends a symbol that already has a documentation comment, \
            and no merge behavior was specified
            """

        case .multiple:
            output[.warning] = """
            markdown supplement extends a symbol that already has a supplement
            """

        case .untitled:
            output[.warning] = """
            markdown supplement has no title
            """
        }
    }
}
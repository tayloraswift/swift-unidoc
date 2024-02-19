import Sources
import SourceDiagnostics

extension SSGC
{
    enum SupplementError:Error, Equatable, Sendable
    {
        case multiple
        case untitled
        case untitledTutorial
        case extraBlocksInTutorial
    }
}
extension SSGC.SupplementError:Diagnostic
{
    typealias Symbolicator = SSGC.Symbolicator

    static
    func += (output:inout DiagnosticOutput<SSGC.Symbolicator>, self:Self)
    {
        switch self
        {
        case .multiple:
            output[.warning] = """
            markdown supplement extends a symbol that already has a supplement
            """

        case .untitled:
            output[.warning] = """
            markdown supplement has no title
            """

        case .untitledTutorial:
            output[.warning] = """
            markdown tutorial has no title
            """

        case .extraBlocksInTutorial:
            output[.warning] = """
            markdown tutorial contains extra blocks
            """
        }
    }
}

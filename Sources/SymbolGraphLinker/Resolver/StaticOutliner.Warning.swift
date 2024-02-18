import Doclinks
import SourceDiagnostics

extension StaticOutliner
{
    enum Warning
    {
        case doclinkNotStaticallyResolvable(Doclink)
    }
}
extension StaticOutliner.Warning:Diagnostic
{
    typealias Symbolicator = StaticSymbolicator

    static
    func += (output:inout DiagnosticOutput<StaticSymbolicator>, self:Self)
    {
        switch self
        {
        case .doclinkNotStaticallyResolvable(let doclink):
            output[.warning] += """
            doclink '\(doclink)' is not statically resolvable
            """

            output[.note] += """
            reformat the doclink as a backtick-delimited codelink to suppress this warning
            """
        }
    }
}

import SourceDiagnostics
import UCF

extension SSGC.Outliner
{
    enum Warning
    {
        case doclinkNotStaticallyResolvable(Doclink)
    }
}
extension SSGC.Outliner.Warning:Diagnostic
{
    typealias Symbolicator = SSGC.Symbolicator

    func emit(summary output:inout DiagnosticOutput<Symbolicator>)
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

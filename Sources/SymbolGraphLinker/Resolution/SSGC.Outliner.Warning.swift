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

    static
    func += (output:inout DiagnosticOutput<SSGC.Symbolicator>, self:Self)
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

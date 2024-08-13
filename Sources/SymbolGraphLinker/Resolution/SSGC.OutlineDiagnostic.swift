import SourceDiagnostics
import UCF

extension SSGC
{
    enum OutlineDiagnostic:Equatable, Error
    {
        case unresolvedAbsolute(Doclink)
        case suggestReformat(Doclink, to:UCF.Selector)
    }
}
extension SSGC.OutlineDiagnostic:Diagnostic
{
    typealias Symbolicator = SSGC.Symbolicator

    func emit(summary output:inout DiagnosticOutput<Symbolicator>)
    {
        switch self
        {
        case .unresolvedAbsolute(let doclink):
            output[.note] = """
            doclink '\(doclink)' does not resolve to any article (or tutorial) in this package
            """

        case .suggestReformat(let doclink, to: _):
            output[.warning] = """
            doclink '\(doclink)' referencing symbol documentation could be written as \
            a backtick-delimited codelink
            """
        }
    }
    func emit(details output:inout DiagnosticOutput<Symbolicator>)
    {
        switch self
        {
        case .unresolvedAbsolute:
            output[.note] = """
            absolute doclinks may only refer to articles (or tutorials), not to symbol \
            documentation
            """

        case .suggestReformat(_, to: let codelink):
            output[.note] = """
            reformat the link as ``\(codelink)`` to suppress this warning
            """
        }
    }
}

import FNV1
import SourceDiagnostics
import UCF

extension SSGC
{
    enum OutlineDiagnostic:Equatable, Error
    {
        case annealedIncorrectHash(in:UCF.Selector, to:FNV24)
        case unresolvedAbsolute(Doclink)
        case unresolvedRelative(Doclink)
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
        case .annealedIncorrectHash(in: let selector, to: _):
            output[.warning] = """
            codelink '\(selector)' is unambiguous, but the hash does not match the resolved \
            declaration
            """

        case .unresolvedAbsolute(let doclink):
            fallthrough

        case .unresolvedRelative(let doclink):
            output[.warning] = """
            doclink '\(doclink.value)' does not resolve to any article (or tutorial) in this package
            """

        case .suggestReformat(let doclink, to: _):
            output[.warning] = """
            doclink '\(doclink.value)' referencing symbol documentation could be written as \
            a backtick-delimited codelink
            """
        }
    }
    func emit(details output:inout DiagnosticOutput<Symbolicator>)
    {
        switch self
        {
        case .annealedIncorrectHash(in: _, to: let hash):
            output[.note] = """
            replace the hash with [\(hash)] to suppress this warning
            """

        case .unresolvedAbsolute:
            output[.note] = """
            absolute doclinks may only refer to articles (or tutorials), not to symbol \
            documentation
            """

        case .unresolvedRelative(let doclink):
            output[.note] = """
            could not convert relative doclink '\(doclink.page)' to a UCF selector
            """

        case .suggestReformat(_, to: let codelink):
            output[.note] = """
            reformat the link as ``\(codelink)`` to suppress this warning
            """
        }
    }
}

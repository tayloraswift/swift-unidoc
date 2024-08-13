import MarkdownAST
import SourceDiagnostics
import Sources

extension SSGC
{
    struct AutolinkParsingError:Equatable, Error
    {
        let string:String
        let source:SourceReference<Markdown.Source>?

        init(string:String, source:SourceReference<Markdown.Source>? = nil)
        {
            self.string = string
            self.source = source
        }
    }
}
extension SSGC.AutolinkParsingError
{
    init(_ value:Markdown.SourceString)
    {
        self.init(string: value.string, source: value.source)
    }
}
extension SSGC.AutolinkParsingError:Diagnostic
{
    typealias Symbolicator = SSGC.Symbolicator

    func emit(summary output:inout DiagnosticOutput<SSGC.Symbolicator>)
    {
        output[.error] += """
        autolink expression '\(self.string)' could not be parsed
        """
    }
}

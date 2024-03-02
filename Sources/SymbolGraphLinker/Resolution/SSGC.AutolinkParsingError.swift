import MarkdownAST
import SourceDiagnostics
import Sources

extension SSGC
{
    struct AutolinkParsingError<Symbolicator>:Equatable, Error
        where Symbolicator:DiagnosticSymbolicator
    {
        public
        let string:String
        public
        let source:SourceReference<Markdown.Source>?

        @inlinable public
        init(string:String, source:SourceReference<Markdown.Source>? = nil)
        {
            self.string = string
            self.source = source
        }
    }
}
extension SSGC.AutolinkParsingError
{
    @inlinable public
    init(_ value:Markdown.SourceString)
    {
        self.init(string: value.string, source: value.source)
    }
}
extension SSGC.AutolinkParsingError:Diagnostic
{
    @inlinable public static
    func += (output:inout DiagnosticOutput<Symbolicator>, self:Self)
    {
        output[.warning] += """
        autolink expression '\(self.string)' could not be parsed
        """
    }
}

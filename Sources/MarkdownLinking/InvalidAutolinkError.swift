import MarkdownAST
import SourceDiagnostics
import Sources

@frozen public
struct InvalidAutolinkError<Symbolicator>:Equatable, Error
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
extension InvalidAutolinkError
{
    @inlinable public
    init(_ value:Markdown.SourceString)
    {
        self.init(string: value.string, source: value.source)
    }
}
extension InvalidAutolinkError:Diagnostic
{
    @inlinable public static
    func += (output:inout DiagnosticOutput<Symbolicator>, self:Self)
    {
        output[.warning] += """
        autolink expression '\(self.string)' could not be parsed
        """
    }
}

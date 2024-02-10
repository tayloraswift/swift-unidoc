import MarkdownAST
import Sources
import UnidocDiagnostics

extension Markdown.InlineAutolink:DiagnosticSubject
{
    /// Returns the **absolute** source location of this autolink.
    public
    var location:SourceLocation<Int32>?
    {
        if  let base:SourceLocation<Int32> = self.source.file.location,
            let offset:Range<SourcePosition> = self.source.range
        {
            base.translated(by: offset.lowerBound)
        }
        else
        {
            nil
        }
    }

    public
    var context:SourceContext
    {
        self.source.range.map { self.source.file[$0] } ?? []
    }
}

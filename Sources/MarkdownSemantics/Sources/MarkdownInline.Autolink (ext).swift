import Sources
import MarkdownAST
import UnidocDiagnostics

extension MarkdownInline.Autolink:DiagnosticSubject
{
    /// Returns the **absolute** source location of this autolink.
    public
    var location:SourceLocation<Int32>?
    {
        if  let base:SourceLocation<Int32> = self.source.file.location,
            let offset:Range<SourcePosition> = self.source.range
        {
            return base.translated(by: offset.lowerBound)
        }
        else
        {
            return nil
        }
    }

    public
    var context:SourceContext
    {
        self.source.range.map { self.source.file[$0] } ?? []
    }
}

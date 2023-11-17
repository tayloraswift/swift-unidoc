import Sources
import MarkdownAST
import UnidocDiagnostics

extension MarkdownSource
{
    /// Extracts a source context for the given source range. This subscript interprets the
    /// range bounds as offsets from ``location``, not the beginning of whatever larger file
    /// the markdown source originated from.
    subscript(range:Range<SourcePosition>) -> SourceContext
    {
        var context:SourceContext = []

        let source:[Substring] = self.text.split(omittingEmptySubsequences: false,
            whereSeparator: \.isNewline)
        let lines:ClosedRange<Int> = range.lowerBound.line ... max(
            range.lowerBound.line,
            range.upperBound.line)
        let shown:Range<Int> = (lines.lowerBound - 1 ..< lines.upperBound + 2).clamped(
            to: source.indices)
        for (l, line):(Int, Substring) in zip(shown, source[shown])
        {
            context.lines.append(.source(String.init(line)))

            if  lines ~= l
            {
                let start:Int = l == lines.lowerBound ? range.lowerBound.column : 0
                let end:Int = l == lines.upperBound ? range.upperBound.column : line.count
                context.lines.append(.annotation(start ... max(start, end - 1)))
            }
        }

        return context
    }
}
extension MarkdownSource:DiagnosticSubject
{
    /// TODO: include text snippet
    public
    var context:SourceContext
    {
        .init()
    }
}

import Sources

/// A `DiagnosticFrame` is something that can provide contextual source code for a
/// ``Diagnostic``.
public
protocol DiagnosticFrame<File>
{
    associatedtype File

    /// The absolute location of the source ``text`` within a larger source file, if known. If
    /// the source text originated from a standalone file, this should be
    /// ``SourcePosition/zero``.
    var origin:SourceLocation<File>? { get }
    /// The full source text.
    var text:String { get }
}
extension DiagnosticFrame
{
    /// Extracts a source context for the given source range. This subscript interprets the
    /// range bounds as offsets from ``location``, not the beginning of whatever larger file
    /// the markdown source originated from.
    subscript(range:Range<SourcePosition>) -> [DiagnosticLine]
    {
        var context:[DiagnosticLine] = []

        let source:[Substring] = self.text.split(omittingEmptySubsequences: false,
            whereSeparator: \.isNewline)
        let lines:ClosedRange<Int> = range.lowerBound.line ... max(
            range.lowerBound.line,
            range.upperBound.line)
        let shown:Range<Int> = (lines.lowerBound - 1 ..< lines.upperBound + 2).clamped(
            to: source.indices)
        for (l, line):(Int, Substring) in zip(shown, source[shown])
        {
            context.append(.source(String.init(line)))

            if  lines ~= l
            {
                let start:Int = l == lines.lowerBound ? range.lowerBound.column : 0
                let end:Int = l == lines.upperBound ? range.upperBound.column : line.count
                context.append(.annotation(start ... max(start, end - 1)))
            }
        }

        return context
    }
}

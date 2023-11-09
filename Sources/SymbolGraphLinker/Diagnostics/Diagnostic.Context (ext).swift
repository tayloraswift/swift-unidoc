import Sources
import UnidocDiagnostics

extension Diagnostic.Context<Int32>
{
    init(of subject:SourceReference<Int>, in sources:borrowing [MarkdownSource])
    {
        self.init(of: subject.range, in: sources[subject.file])
    }
    init(of range:Range<SourcePosition>, in source:borrowing MarkdownSource)
    {
        self.init(location: source.location.map { $0.translated(by: range.lowerBound) } ?? nil)

        let source:[Substring] = source.text.split(omittingEmptySubsequences: false,
            whereSeparator: \.isNewline)
        let lines:ClosedRange<Int> = range.lowerBound.line ... max(
            range.lowerBound.line,
            range.upperBound.line)
        let shown:Range<Int> = (lines.lowerBound - 1 ..< lines.upperBound + 2).clamped(
            to: source.indices)
        for (l, line):(Int, Substring) in zip(shown, source[shown])
        {
            self.lines.append(.source(String.init(line)))

            if  lines ~= l
            {
                let start:Int = l == lines.lowerBound ? range.lowerBound.column : 0
                let end:Int = l == lines.upperBound ? range.upperBound.column : line.count
                self.lines.append(.annotation(start ... max(start, end - 1)))
            }
        }
    }
}

import Sources
import SymbolGraphs
import Symbols

extension StaticDiagnostic
{
    struct Context<File>
    {
        let header:Header?
        private(set)
        var lines:[Line]

        private
        init(header:Header?, lines:[Line] = [])
        {
            self.header = header
            self.lines = lines
        }
    }
}
extension StaticDiagnostic.Context<Int32>
{
    init(of subject:SourceText<Int>, in sources:__shared [MarkdownSource])
    {
        self.init(of: subject.range, in: sources[subject.file])
    }
    init(of range:Range<SourcePosition>, in source:__shared MarkdownSource)
    {
        if  let origin:SourceLocation<Int32> = source.location
        {
            self.init(header: .init(file: origin.file,
                line: origin.position.line + range.lowerBound.line,
                column: origin.position.column + range.lowerBound.column))
        }
        else
        {
            self.init(header: nil)
        }

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

    func symbolicated(with symbolicator:Symbolicator) -> StaticDiagnostic.Context<String>
    {
        .init(
            header: self.header.map { $0.symbolicated(with: symbolicator) },
            lines: self.lines)
    }
}

import Sources

extension StaticDiagnostic
{
    struct Context
    {
        let lines:String
    }
}
extension StaticDiagnostic.Context
{
    init(of subject:SourceText<Int>, in sources:__shared [MarkdownSource])
    {
        let source:MarkdownSource = sources[subject.file]
        let lines:[Substring] = source.text.split(omittingEmptySubsequences: false,
            whereSeparator: \.isNewline)
        let shown:Range<Int> =
            max(lines.startIndex, subject.range.lowerBound.line - 1) ..<
            min(lines.endIndex,   subject.range.upperBound.line + 2)
        // let start:SourceLocation<Int32>? = (source.location?.file).map
        // {
        //     (file:Int32) in subject.start.map { _ in file }
        // }
        self.init(lines: lines[shown].joined(separator: "\n"))
    }
}

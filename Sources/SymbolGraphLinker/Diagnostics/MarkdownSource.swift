import Sources
import SymbolGraphCompiler
import UnidocDiagnostics

struct MarkdownSource
{
    /// The absolute location of the markdown source within a larger source file,
    /// if known. If the markdown source was a standalone markdown file, this is
    /// ``SourceLocation/zero``.
    let location:SourceLocation<Int32>?
    /// The unparsed markdown source text.
    let text:String

    init(location:SourceLocation<Int32>?, text:String)
    {
        self.location = location
        self.text = text
    }
}
extension MarkdownSource
{
    init(comment:borrowing Compiler.Doccomment, in file:Int32?)
    {
        if  let position:SourcePosition = comment.start,
            let file:Int32
        {
            self.init(location: .init(position: position, file: file), text: comment.text)
        }
        else
        {
            self.init(location: nil, text: comment.text)
        }
    }
}
extension MarkdownSource
{
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
    var context:SourceContext
    {
        .init()
    }
}

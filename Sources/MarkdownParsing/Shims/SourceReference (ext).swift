import Markdown
import Sources

extension SourceReference
{
    init(file:File, trimming trim:Int = 0, from range:Range<Markdown.SourceLocation>?)
    {
        if  let range:Range<Markdown.SourceLocation>,
            let start:SourcePosition = .init(range.lowerBound, offset: trim),
            let end:SourcePosition = .init(range.upperBound, offset: -trim)
        {
            self.init(file: file, range: start ..< max(start, end))
        }
        else
        {
            self.init(file: file, range: nil)
        }
    }
}

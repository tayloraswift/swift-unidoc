import Markdown
import Sources

extension SourceText
{
    init?(_ range:Range<Markdown.SourceLocation>?, in file:File, trimming trim:Int = 0)
    {
        if  let range,
            let start:SourcePosition = .init(range.lowerBound, offset: trim),
            let end:SourcePosition = .init(range.upperBound, offset: -trim)
        {
            self.init(range: start ..< max(start, end), file: file)
        }
        else
        {
            return nil
        }
    }
}

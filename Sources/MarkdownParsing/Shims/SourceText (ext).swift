import Markdown
import Sources

extension SourceText
{
    init?(_ range:Range<Markdown.SourceLocation>?, in file:File)
    {
        if  let range,
            let start:SourcePosition = .init(range.lowerBound),
            let end:SourcePosition = .init(range.upperBound)
        {
            self.init(range: start ..< end, file: file)
        }
        else
        {
            return nil
        }
    }
}

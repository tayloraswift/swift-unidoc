import MarkdownABI
import MarkdownSemantics

extension Markdown.BlockCodeReference
{
    func inline(
        code:StaticLinker.ResourceText,
        base:StaticLinker.ResourceText?,
        with swift:Markdown.SwiftLanguage?)
    {
        if  case "swift"? = self.language,
            let swift:Markdown.SwiftLanguage
        {
            self.code = swift.parse(code: code.whole, diff: code.diff(from: base))
        }
        else if
            let base:StaticLinker.ResourceText
        {
            self.code = .init
            {
                for (range, color):(Range<Int>, Markdown.DiffType?) in code.diff(from: base)
                {
                    if  let color:Markdown.DiffType
                    {
                        $0[.diff(color)] { $0 += code.whole[range] }
                    }
                    else
                    {
                        $0 += code.whole[range]
                    }
                }
            }
        }
        else
        {
            self.code = .init(bytes: code.whole)
        }
    }
}

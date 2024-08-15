import MarkdownAST
import UCF

extension Markdown.SourceURL
{
    var translatableSelector:UCF.Selector?
    {
        //  Skip the two slashes.
        guard
        let start:String.Index = self.suffix.string.index(self.suffix.string.startIndex,
            offsetBy: 2,
            limitedBy: self.suffix.string.endIndex),
        case "//" = self.suffix.string[..<start]
        else
        {
            return nil
        }

        guard
        let slash:String.Index = self.suffix.string[start...].firstIndex(of: "/")
        else
        {
            return nil
        }

        return .translate(
            domain: self.suffix.string[start ..< slash],
            path: self.suffix.string[slash...])
    }
}

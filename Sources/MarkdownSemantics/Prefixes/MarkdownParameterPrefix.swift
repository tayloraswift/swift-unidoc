import Codelinks
import MarkdownAST

struct MarkdownParameterPrefix:Equatable, Hashable, Sendable
{
    let name:String

    init(name:String)
    {
        self.name = name
    }
}
extension MarkdownParameterPrefix:MarkdownSemanticPrefix
{
    static
    var radius:Int { 4 }

    /// Detects an instance of this pattern type from the given array of
    /// inline block content. The array contains inline content up to, but
    /// not including, an unformatted `:` character.
    init?(from elements:__shared [MarkdownInline.Block])
    {
        let words:[Substring] = elements.lazy.map(\.text).joined().split(maxSplits: 1,
            omittingEmptySubsequences: true,
            whereSeparator: \.isWhitespace)

        if  words.count == 2,
            words[0].lowercased() == "parameter"
        {
            //  Don’t attempt to validate the identifier for disallowed characters,
            //  this is the wrong place for that.
            self.init(name: String.init(words[1]))
        }
        else
        {
            return nil
        }
    }
}

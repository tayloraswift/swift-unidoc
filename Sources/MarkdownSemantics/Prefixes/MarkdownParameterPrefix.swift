import Codelinks
import MarkdownTrees

struct MarkdownParameterPrefix:Equatable, Hashable, Sendable
{
    let identifier:Codelink.Identifier

    init(identifier:Codelink.Identifier)
    {
        self.identifier = identifier
    }
}
extension MarkdownParameterPrefix:MarkdownSemanticPrefix
{
    static
    var radius:Int { 4 }

    /// Detects an instance of this pattern type from the given array of
    /// inline block content. The array contains inline content up to, but
    /// not including, an unformatted `:` character.
    init?(from elements:__shared [MarkdownTree.InlineBlock])
    {
        let words:[Substring] = elements.lazy.map(\.text).joined().split(maxSplits: 1,
            omittingEmptySubsequences: true,
            whereSeparator: \.isWhitespace)
        
        if  words.count == 2,
            words[0].lowercased() == "parameter",
            let identifier:Codelink.Identifier = .init(words[1])
        {
            self.init(identifier: identifier)
        }
        else
        {
            return nil
        }
    }
}

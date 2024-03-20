extension Markdown
{
    protocol DefinePrefix:SemanticPrefix
    {
        /// A lowercased keyword that begins this prefix pattern.
        static
        var keyword:String { get }

        init(name:String, as style:DefineStyle)
    }
}
extension Markdown.DefinePrefix
{
    /// This is `4` to accommodate formatted definitions. The first span would be the formatted
    /// ``keyword``, the second span would contain the unformatted whitespace between the
    /// keyword and the name, the third span would be formatted name, and the fourth span would
    /// would contain the `:` separator, including any leading whitespace.
    static
    var radius:Int { 4 }

    /// Detects an instance of this pattern type from the given array of
    /// inline block content. The array contains inline content up to, but
    /// not including, an unformatted `:` character.
    init?(from elements:__shared [Markdown.InlineElement])
    {
        let words:[Substring] = elements.lazy.map(\.text).joined().split(maxSplits: 1,
            omittingEmptySubsequences: true,
            whereSeparator: \.isWhitespace)

        guard words.count == 2,
        case Self.keyword = words[0].lowercased()
        else
        {
            return nil
        }

        let style:Markdown.DefineStyle
        if  case .code? = elements.last
        {
            style = .code
        }
        else
        {
            style = .text
        }
        //  Don’t attempt to validate the identifier for disallowed characters,
        //  this is the wrong place for that.
        self.init(name: String.init(words[1]), as: style)
    }
}

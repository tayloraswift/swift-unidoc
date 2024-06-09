extension SnippetParser.SliceMarker
{
    enum Statement
    {
        case end
        case hide
        case show
        case slice(String)
    }
}
extension SnippetParser.SliceMarker.Statement
{
    private
    init(word:Substring)
    {
        switch word
        {
        case "end":     self = .end
        case "hide":    self = .hide
        case "show":    self = .show
        default:        self = .slice(String.init(word))
        }
    }

    init?(trimmedLine text:borrowing Substring)
    {
        guard
        let j:String.Index = text.firstIndex(of: "."),
        case "snippet" = text[..<j]
        else
        {
            return nil
        }

        let k:String.Index = text.index(after: j)
        if  let space:String.Index = text[k...].firstIndex(where: \.isWhitespace)
        {
            guard text[text.index(after: space)...].allSatisfy(\.isWhitespace)
            else
            {
                return nil
            }

            self.init(word: text[k ..< space])
        }
        else
        {
            self.init(word: text[k...])
        }
    }
}

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
    init(_ text:Substring)
    {
        switch text
        {
        case "end":     self = .end
        case "hide":    self = .hide
        case "show":    self = .show
        default:        self = .slice(String.init(text))
        }
    }

    init?(lineComment text:borrowing String, skip:Int)
    {
        guard
        let i:String.Index = text.index(text.startIndex,
            offsetBy: skip,
            limitedBy: text.endIndex)
        else
        {
            fatalError("Encountered a line comment with no leading slashes!")
        }

        let text:Substring = text[i...].drop(while: \.isWhitespace)

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

            self.init(text[k ..< space])
        }
        else
        {
            self.init(text[k...])
        }
    }
}

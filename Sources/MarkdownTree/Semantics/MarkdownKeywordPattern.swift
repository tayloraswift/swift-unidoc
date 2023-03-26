public
protocol MarkdownKeywordPattern:MarkdownPrefixPattern, LosslessStringConvertible
{
    /// The maximum number of space- or hyphen-separated words that any
    /// keyword of this type can be written with.
    static
    var words:Int { get }
}
extension MarkdownKeywordPattern
{
    /// If a keyword pattern uses formatting, the formatting must apply
    /// to the entire pattern.
    public static
    var range:Int { 2 }

    public
    init?(from spans:__shared [MarkdownTree.InlineBlock])
    {
        if spans.count == 1
        {
            self.init(spans[0].text)
        }
        else
        {
            return nil
        }
    }
}
extension MarkdownKeywordPattern where Self:RawRepresentable<String>
{
    public
    init?(_ description:String)
    {
        var lowercased:String = ""
            lowercased.reserveCapacity(description.utf8.count)
        var words:Int = 0
        for character:Character in description
        {
            if      character.isLetter
            {
                lowercased.append(character.lowercased())
            }
            else if character == " " || 
                    character == "-",
                    words < Self.words
            {
                words += 1
                continue
            }
            else
            {
                return nil
            }
        }
        self.init(rawValue: lowercased)
    }
}

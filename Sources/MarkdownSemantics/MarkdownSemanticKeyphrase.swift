import MarkdownTrees

public
protocol MarkdownSemanticKeyphrase:MarkdownSemanticPrefix
{
    /// The maximum number of space- or hyphen-separated words that any
    /// keyword of this type can be written with.
    static
    var words:Int { get }

    /// Detects an instance of this pattern type from the given string.
    /// The string is all-lowercased and devoid of whitespace.
    init?(lowercased:String)
}
extension MarkdownSemanticKeyphrase
{
    /// If a keyword pattern uses formatting, the formatting must apply
    /// to the entire pattern.
    public static
    var radius:Int { 2 }

    public
    init?(from elements:__shared [MarkdownTree.InlineBlock])
    {
        if  elements.count == 1
        {
            self.init(elements[0].text)
        }
        else
        {
            return nil
        }
    }

    private
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
        self.init(lowercased: lowercased)
    }
}

public
protocol MarkdownText:MarkdownElement
{
    /// Writes the plain text content of this element to the input string.
    static
    func += (text:inout String, self:Self)

    /// Returns the plain text content of this element.
    var text:String { get }
}
extension MarkdownText
{
    @inlinable public
    var text:String
    {
        var text:String = ""
        text += self
        return text
    }
}

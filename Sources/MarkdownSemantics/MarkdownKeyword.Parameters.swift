extension MarkdownKeyword
{
    @frozen public
    enum Parameters:String, Equatable, Hashable, Sendable
    {
        case parameters
    }
}
extension MarkdownKeyword.Parameters:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .parameters: return "Parameters"
        }
    }
}
extension MarkdownKeyword.Parameters:MarkdownKeywordPattern
{
    public static
    var words:Int { 1 }
}

extension MarkdownTree
{
    @frozen public
    enum Parameters:String, Equatable, Hashable, Sendable
    {
        case parameters
    }
}
extension MarkdownTree.Parameters:CustomStringConvertible
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
extension MarkdownTree.Parameters:MarkdownKeywordPattern
{
    public static
    var words:Int { 1 }
}

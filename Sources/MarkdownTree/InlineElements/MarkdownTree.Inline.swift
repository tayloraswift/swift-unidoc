extension MarkdownTree
{
    @frozen public
    enum Inline
    {
        case container(InlineContainer<Self>)
        case code(String)
        case html(String)
        case text(String)
    }
}
extension MarkdownTree.Inline:MarkdownTextConvertibleElement
{
    @inlinable public
    var text:String
    {
        switch self
        {
        case .container(let container):
            return container.text
        
        case .code(let text), .text(let text):
            return text
        
        case .html:
            return ""
        }
    }
}

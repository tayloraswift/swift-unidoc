extension MarkdownTree
{
    @frozen public
    enum InlineBlock
    {
        case container(InlineContainer<Self>)
        case code(String)
        case html(String)
        case image(Image)
        case link(Link)
        case symbol(String)
        case text(String)
    }
}
extension MarkdownTree.InlineBlock:MarkdownTextConvertibleElement
{
    @inlinable public
    var text:String
    {
        switch self
        {
        case .container(let container):
            return container.text
        
        case .code(let text), .symbol(let text), .text(let text):
            return text
        
        case .html:
            return ""
        
        case .image(let image):
            return image.text
        
        case .link(let link):
            return link.text
        }
    }
}

import MarkdownABI

extension MarkdownTree
{
    @frozen public
    enum InlineBlock
    {
        case container(InlineContainer<Self>)
        
        case code(InlineCode, symbol:Bool = false)
        case html(InlineHTML)
        case image(Image)
        case link(Link)

        case reference(UInt32)

        case text(String)
    }
}
extension MarkdownTree.InlineBlock:MarkdownBinaryConvertibleElement
{
    @inlinable public
    func emit(into binary:inout MarkdownBinary)
    {
        switch self
        {
        case .container(let container):
            container.emit(into: &binary)
        
        case .code(let code, symbol: _):
            code.emit(into: &binary)
        
        case .html(let html):
            html.emit(into: &binary)
        
        case .image(let image):
            image.emit(into: &binary)
        
        case .link(let link):
            link.emit(into: &binary)
        
        case .reference(let reference):
            binary.write(reference: reference)

        case .text(let unescaped):
            binary.write(text: unescaped)
        }
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
        
        case .code(let code, symbol: _):
            return code.text
        
        case .html, .reference:
            return ""
        
        case .image(let image):
            return image.text
        
        case .link(let link):
            return link.text
        
        case .text(let text):
            return text
        }
    }
}

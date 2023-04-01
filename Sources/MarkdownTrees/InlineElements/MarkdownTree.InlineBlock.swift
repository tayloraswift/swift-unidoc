import MarkdownABI

extension MarkdownTree
{
    @frozen public
    enum InlineBlock
    {
        case referenceLink(String)
        case inlineLink(InlineLink)

        case container(InlineContainer<Self>)
        
        case code(String)
        case html(String)
        case image(Image)
        case text(String)
    }
}
extension MarkdownTree.InlineBlock:MarkdownBinaryConvertibleElement
{
    @inlinable public
    func serialize(into binary:inout MarkdownBinary)
    {
        let element:MarkdownBinary.ContainerType
        let text:String

        switch self
        {
        case .container(let container):
            container.serialize(into: &binary)
        
        case .code(let code):
            binary[.code] { $0.write(text: code) }
        
        case .html(let escaped):
            binary[.none] { $0.write(text: escaped) }

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

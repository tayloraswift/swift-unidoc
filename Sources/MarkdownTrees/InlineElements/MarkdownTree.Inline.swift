import MarkdownABI

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
extension MarkdownTree.Inline:MarkdownBinaryConvertibleElement
{
    @inlinable public
    func serialize(into binary:inout MarkdownBinary)
    {
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

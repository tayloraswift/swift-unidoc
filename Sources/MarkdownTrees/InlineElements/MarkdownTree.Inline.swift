import MarkdownABI

extension MarkdownTree
{
    @frozen public
    enum Inline
    {
        case container(InlineContainer<Self>)
        case code(InlineCode)
        case html(InlineHTML)
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
        case .container(let container): return container.text
        case .code(let code):           return code.text
        case .html:                     return ""
        case .text(let text):           return text
        }
    }
}
extension MarkdownTree.Inline:MarkdownBinaryConvertibleElement
{
    @inlinable public
    func emit(into binary:inout MarkdownBinary)
    {
        switch self
        {
        case .container(let container):
            container.emit(into: &binary)
        
        case .code(let code):
            code.emit(into: &binary)
        
        case .html(let html):
            html.emit(into: &binary)

        case .text(let unescaped):
            binary.write(text: unescaped)
        }
    }
}

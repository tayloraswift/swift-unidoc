import MarkdownABI

@frozen public
enum MarkdownInline:Equatable, Hashable, Sendable
{
    case container(Container<Self>)
    case code(Code)
    case html(HTML)
    case text(String)
}
extension MarkdownInline:MarkdownElement
{
    @inlinable public
    func emit(into binary:inout MarkdownBinaryEncoder)
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
extension MarkdownInline:MarkdownText
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

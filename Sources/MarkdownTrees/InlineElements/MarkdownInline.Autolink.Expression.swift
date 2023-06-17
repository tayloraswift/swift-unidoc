extension MarkdownInline.Autolink
{
    @frozen public
    enum Expression
    {
        case codelink(String)
        case doclink(String)
    }
}
extension MarkdownInline.Autolink.Expression
{
    @inlinable internal
    var element:MarkdownInline.Block
    {
        switch self
        {
        case .codelink(let text):   return .code(.init(text: text))
        case .doclink(let uri):     return .link(.init(url: "doc:\(uri)"))
        }
    }
}

extension Markdown
{
    enum TextContext
    {
        case invisible
        case visible
    }
}
extension Markdown.TextContext
{
    init(from markdown:Markdown.Bytecode.Context)
    {
        switch markdown
        {
        case .transparent:  self = .invisible
        case _:             self = .visible
        }
    }
}

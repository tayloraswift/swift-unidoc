import MarkdownABI

enum MarkdownTextContext
{
    case invisible
    case visible

    init(from markdown:MarkdownBytecode.Context)
    {
        switch markdown
        {
        case .transparent:  self = .invisible
        case _:             self = .visible
        }
    }
}

import MarkdownAST

extension StaticLinker.Supplement
{
    @frozen public
    enum Headline
    {
        case binding(Markdown.InlineAutolink)
        case heading(Markdown.BlockHeading)
    }
}
extension StaticLinker.Supplement.Headline
{
    @inlinable public
    var binding:Markdown.InlineAutolink?
    {
        switch self
        {
        case .binding(let binding): binding
        case .heading:              nil
        }
    }
}
extension StaticLinker.Supplement.Headline
{
    init(_ heading:Markdown.BlockHeading)
    {
        //  Do not expect exactly one inline element, there may be HTML comments.
        if  case .autolink(let binding)? = heading.elements.first
        {
            self = .binding(binding)
        }
        else
        {
            self = .heading(heading)
        }
    }
}

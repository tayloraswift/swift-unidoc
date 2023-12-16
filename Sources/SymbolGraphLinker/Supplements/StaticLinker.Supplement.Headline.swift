import MarkdownAST

extension StaticLinker.Supplement
{
    @frozen public
    enum Headline
    {
        case binding(MarkdownInline.Autolink)
        case heading(MarkdownBlock.Heading)
    }
}
extension StaticLinker.Supplement.Headline
{
    @inlinable public
    var binding:MarkdownInline.Autolink?
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
    init(_ heading:MarkdownBlock.Heading)
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

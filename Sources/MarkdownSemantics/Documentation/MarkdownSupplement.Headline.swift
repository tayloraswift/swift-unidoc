import MarkdownTrees

extension MarkdownSupplement
{
    @frozen public
    enum Headline
    {
        case binding(MarkdownInline.Autolink)
        case heading(MarkdownBlock.Heading)
    }
}
extension MarkdownSupplement.Headline
{
    init(_ heading:MarkdownBlock.Heading)
    {
        if  heading.elements.count == 1,
            case .autolink(let binding) = heading.elements[0]
        {
            self = .binding(binding)
        }
        else
        {
            self = .heading(heading)
        }
    }
}

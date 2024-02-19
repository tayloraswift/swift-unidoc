import MarkdownAST

extension SSGC.Supplement
{
    @frozen public
    enum Headline
    {
        case supplement(Markdown.InlineAutolink)
        case standalone(Markdown.BlockHeading)
        case tutorials(String)
        case tutorial(String)
    }
}
extension SSGC.Supplement.Headline
{
    @inlinable public
    var binding:Markdown.InlineAutolink?
    {
        switch self
        {
        case .supplement(let binding):  binding
        case .standalone:               nil
        case .tutorials:                nil
        case .tutorial:                 nil
        }
    }
}
extension SSGC.Supplement.Headline
{
    init(_ heading:Markdown.BlockHeading)
    {
        //  Do not expect exactly one inline element, there may be HTML comments.
        if  case .autolink(let binding)? = heading.elements.first
        {
            self = .supplement(binding)
        }
        else
        {
            self = .standalone(heading)
        }
    }
}

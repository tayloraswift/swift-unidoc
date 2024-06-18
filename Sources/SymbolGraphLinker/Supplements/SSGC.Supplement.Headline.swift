import MarkdownAST
import Sources

extension SSGC.Supplement
{
    @frozen public
    enum Headline
    {
        case supplementWithHeading(Markdown.Bytecode)
        case supplement(Markdown.InlineAutolink)
        case standalone(Markdown.Bytecode, at:SourceReference<Markdown.Source>?)
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
        case .supplementWithHeading:    nil
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
            let headline:Markdown.Bytecode = .init
            {
                //  Don’t emit the enclosing `h1` tag!
                for element:Markdown.InlineElement in heading.elements
                {
                    element.emit(into: &$0)
                }
            }

            self = .standalone(headline, at: heading.source)
        }
    }
}

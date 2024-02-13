import MarkdownAST
import MarkdownSemantics

extension StaticLinker
{
    @frozen public
    enum Supplement
    {
        case supplement(Headline, Markdown.SemanticDocument)
        case tutorials(Markdown.BlockDirective)
        case tutorial(Markdown.Tutorial)
        case untitled
    }
}
extension StaticLinker.Supplement
{
    @inlinable public
    var headline:Headline?
    {
        switch self
        {
        case .supplement(let headline, _):  headline
        case .tutorials:                    nil
        case .tutorial:                     nil
        case .untitled:                     nil
        }
    }
}

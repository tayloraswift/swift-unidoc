import MarkdownAST
import MarkdownSemantics

extension StaticLinker
{
    @_spi(testable)
    @frozen public
    enum Supplement
    {
        case supplement(Headline, Markdown.SemanticDocument)
        case tutorials(Markdown.BlockDirective)
        case tutorial(String, Markdown.SemanticDocument)
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
        }
    }
}

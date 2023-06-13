import Codelinks
import MarkdownTrees

@frozen public
struct MarkdownDocumentationSupplement
{
    public
    let headline:MarkdownBlock.Heading?
    public
    var article:MarkdownDocumentation

    public
    init(headline:MarkdownBlock.Heading?, article:MarkdownDocumentation)
    {
        self.headline = headline
        self.article = article
    }
}
extension MarkdownDocumentationSupplement
{
    public
    var binding:Codelink?
    {
        if  let headline:MarkdownBlock.Heading = self.headline,
                headline.elements.count == 1,
            case .code(let expression, symbol: true) = headline.elements[0]
        {
            return .init(parsing: expression.text)
        }
        else
        {
            return nil
        }
    }
}
extension MarkdownDocumentationSupplement:MarkdownModel
{
    public
    func visit(_ yield:(MarkdownBlock) throws -> ()) rethrows
    {
        try self.headline.map(yield)
        try self.article.visit(yield)
    }

    public
    init(attaching blocks:[MarkdownBlock])
    {
        if  case (let headline as MarkdownBlock.Heading)? = blocks.first, headline.level == 1
        {
            self.init(headline: headline, article: .init(attaching: blocks.dropFirst()))
        }
        else
        {
            self.init(headline: nil, article: .init(attaching: blocks))
        }
    }
}

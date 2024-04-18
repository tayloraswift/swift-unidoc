import HTML

extension Unidoc
{
    enum AnyCard
    {
        case article(ArticleCard)
        case culture(CultureCard)
        case decl(DeclCard)
        case product(ProductCard)
    }
}
extension Unidoc.AnyCard:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.AttributeEncoder, self:Self)
    {
        switch self
        {
        case .article(let card):    html += card
        case .culture(let card):    html += card
        case .decl(let card):       html += card
        case .product(let card):    html += card
        }
    }

    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        switch self
        {
        case .article(let card):    html += card
        case .culture(let card):    html += card
        case .decl(let card):       html += card
        case .product(let card):    html += card
        }
    }
}

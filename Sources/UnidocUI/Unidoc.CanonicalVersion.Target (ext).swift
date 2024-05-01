extension Unidoc.CanonicalVersion.Target
{
    var indefiniteArticle:String
    {
        switch self
        {
        case .article:          "An"
        case .culture:          "A"
        case .decl:             "A"
        case .product:          "A"
        case .foreign:          "An"
        case .landing:          "A"
        }
    }
    var demonym:String
    {
        switch self
        {
        case .article:          "article"
        case .culture:          "module"
        case .decl:             "symbol"
        case .product:          "package product"
        case .foreign:          "extension overlay"
        case .landing:          "package"
        }
    }
    var identity:String
    {
        switch self
        {
        case .article:          "name"
        case .culture:          "name"
        case .decl:             "signature"
        case .product:          "name"
        case .foreign:          "base declaration"
        case .landing:          "identity"
        }
    }
}

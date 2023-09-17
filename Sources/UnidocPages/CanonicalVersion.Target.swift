import URI

extension CanonicalVersion
{
    @frozen @usableFromInline internal
    enum Target
    {
        case article(URI?)
        case culture(URI?)
        case decl(URI?)
        case meta
    }
}
extension CanonicalVersion.Target
{
    var indefiniteArticle:String
    {
        switch self
        {
        case .article:          return "An"
        case .culture:          return "A"
        case .decl:             return "A"
        case .meta:             return "A"
        }
    }
    var demonym:String
    {
        switch self
        {
        case .article:          return "article"
        case .culture:          return "module"
        case .decl:             return "symbol"
        case .meta:             return "package"
        }
    }
    var identity:String
    {
        switch self
        {
        case .article:          return "name"
        case .culture:          return "name"
        case .decl:             return "signature"
        case .meta:             return "identity"
        }
    }

    var uri:URI?
    {
        switch self
        {
        case .article(let uri): return uri
        case .culture(let uri): return uri
        case .decl(let uri):    return uri
        case .meta:             return nil
        }
    }
}

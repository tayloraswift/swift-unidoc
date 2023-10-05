import URI

extension CanonicalVersion
{
    @frozen @usableFromInline internal
    enum Target
    {
        case article(URI?)
        case culture(URI?)
        case decl(URI?)
        case foreign(URI?)
        case global
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
        case .foreign:          return "An"
        case .global:           return "A"
        }
    }
    var demonym:String
    {
        switch self
        {
        case .article:          return "article"
        case .culture:          return "module"
        case .decl:             return "symbol"
        case .foreign:          return "extension overlay"
        case .global:           return "package"
        }
    }
    var identity:String
    {
        switch self
        {
        case .article:          return "name"
        case .culture:          return "name"
        case .decl:             return "signature"
        case .foreign:          return "base declaration"
        case .global:           return "identity"
        }
    }

    var uri:URI?
    {
        switch self
        {
        case .article(let uri): return uri
        case .culture(let uri): return uri
        case .decl(let uri):    return uri
        case .foreign(let uri): return uri
        case .global:           return nil
        }
    }
}

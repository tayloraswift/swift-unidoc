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
        case .article:          "An"
        case .culture:          "A"
        case .decl:             "A"
        case .foreign:          "An"
        case .global:           "A"
        }
    }
    var demonym:String
    {
        switch self
        {
        case .article:          "article"
        case .culture:          "module"
        case .decl:             "symbol"
        case .foreign:          "extension overlay"
        case .global:           "package"
        }
    }
    var identity:String
    {
        switch self
        {
        case .article:          "name"
        case .culture:          "name"
        case .decl:             "signature"
        case .foreign:          "base declaration"
        case .global:           "identity"
        }
    }

    var uri:URI?
    {
        switch self
        {
        case .article(let uri): uri
        case .culture(let uri): uri
        case .decl(let uri):    uri
        case .foreign(let uri): uri
        case .global:           nil
        }
    }
}

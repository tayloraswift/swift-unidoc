import URI

extension Unidoc.CanonicalVersion
{
    @frozen public
    enum Target
    {
        case article(URI?)
        case culture(URI?)
        case decl(URI?)
        case product(URI?)
        case foreign(URI?)
        case global
    }
}
extension Unidoc.CanonicalVersion.Target
{
    @inlinable public
    var uri:URI?
    {
        switch self
        {
        case .article(let uri): uri
        case .culture(let uri): uri
        case .decl(let uri):    uri
        case .product(let uri): uri
        case .foreign(let uri): uri
        case .global:           nil
        }
    }
}

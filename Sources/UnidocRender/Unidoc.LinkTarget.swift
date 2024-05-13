extension Unidoc
{
    @frozen public
    enum LinkTarget:Sendable
    {
        /// This is a link to a different page that has been exported to another domain.
        /// The payload does not include the domain.
        case exported(String)
        /// This is a link to a different page that originates from the same domain.
        case location(String)
        /// This is a link to the current page.
        case loopback
    }
}
extension Unidoc.LinkTarget
{
    @inlinable public
    var url:String?
    {
        switch self
        {
        case .exported(let uri):    "https://swiftinit.org\(uri)"
        case .location(let uri):    uri
        case .loopback:             nil
        }
    }
}

import URI

extension Unidoc
{
    @frozen public
    enum ServerRoot:String, Sendable
    {
        case account
        case admin
        case asset
        case auth
        case blog = "articles"
        case builder
        case consumers
        case docs
        case docc
        case form
        case help
        case hist
        case hook
        case login
        case lunr
        case plugin
        case ptcl
        case pdct
        case realm
        case really
        case ref
        case render
        case robots_txt = "robots.txt"
        case rules
        case runs
        case sitemap_xml = "sitemap.xml"
        case stats
        case tags
        case telescope
        case user

        /// Deprecated.
        case guides
        /// Deprecated.
        case reference
        /// Deprecated.
        case sitemaps
    }
}
extension Unidoc.ServerRoot
{
    @inlinable public
    var subdomain:Subdomain?
    {
        switch self
        {
        case .ref:      .api
        case .render:   .api
        default:        nil
        }
    }
}
extension Unidoc.ServerRoot
{
    @inlinable public static
    func / (self:consuming Self, next:consuming String) -> URI
    {
        var path:URI.Path = self.path
        path.append(next)
        return .init(path: path)
    }
}
extension Unidoc.ServerRoot:CustomStringConvertible
{
    @inlinable public
    var description:String { "/\(self.rawValue)" }
}
extension Unidoc.ServerRoot
{
    @inlinable public
    var path:URI.Path { [.push(self.rawValue)] }

    @inlinable public
    var uri:URI { .init(path: self.path) }
}

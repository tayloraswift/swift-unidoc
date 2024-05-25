import URI

extension Unidoc
{
    @frozen public
    enum ServerRoot:String, Sendable
    {
        case account
        case admin
        case api
        case asset
        case auth
        case blog = "articles"
        case docs
        case docc
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
        case robots_txt = "robots.txt"
        case sitemap_xml = "sitemap.xml"
        case ssgc
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
    @inlinable public static
    func / (self:consuming Self, next:consuming String) -> URI
    {
        var uri:URI = self.uri

        uri.path.append(next)

        return uri
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
    var uri:URI { [.push(self.rawValue)] }
}

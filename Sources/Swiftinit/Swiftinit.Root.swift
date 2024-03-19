import URI

extension Swiftinit
{
    @frozen public
    enum Root
    {
        case acct
        case admin
        case api
        case asset
        case blog
        case docs
        case docc
        case help
        case hist
        case login
        case lunr
        case plugin
        case ptcl
        case pdct
        case realm
        case really
        case stats
        case tags
        case telescope
    }
}
extension Swiftinit.Root
{
    @inlinable public static
    func / (self:consuming Self, next:consuming String) -> URI
    {
        var uri:URI = self.uri

        uri.path.append(next)

        return uri
    }
}
extension Swiftinit.Root:CustomStringConvertible
{
    @inlinable public
    var description:String { "/\(self.id)" }
}
extension Swiftinit.Root:Identifiable
{
    @inlinable public
    var id:String
    {
        switch self
        {
        case .acct:         "acct"
        case .admin:        "admin"
        case .api:          "api"
        case .asset:        "asset"
        case .blog:         "articles"
        case .docs:         "docs"
        case .docc:         "docc"
        case .help:         "help"
        case .hist:         "hist"
        case .login:        "login"
        case .lunr:         "lunr"
        case .plugin:       "plugin"
        case .ptcl:         "ptcl"
        case .pdct:         "pdct"
        case .realm:        "realm"
        case .really:       "really"
        case .stats:        "stats"
        case .tags:         "tags"
        case .telescope:    "telescope"
        }
    }
}
extension Swiftinit.Root
{
    @inlinable public
    var uri:URI { [.push(self.id)] }
}

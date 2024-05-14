import URI

extension Unidoc
{
    @frozen public
    enum ServerRoot
    {
        case account
        case admin
        case api
        case asset
        case auth
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
        case ssgc
        case stats
        case tags
        case telescope
        case user
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
    var description:String { "/\(self.id)" }
}
extension Unidoc.ServerRoot:Identifiable
{
    @inlinable public
    var id:String
    {
        switch self
        {
        case .account:      "account"
        case .admin:        "admin"
        case .api:          "api"
        case .asset:        "asset"
        case .auth:         "auth"
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
        case .ssgc:         "ssgc"
        case .stats:        "stats"
        case .tags:         "tags"
        case .telescope:    "telescope"
        case .user:         "user"
        }
    }
}
extension Unidoc.ServerRoot
{
    @inlinable public
    var uri:URI { [.push(self.id)] }
}

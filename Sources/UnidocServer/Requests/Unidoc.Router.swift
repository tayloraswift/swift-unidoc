import GitHubAPI
import HTTP
import IP
import JSON
import MD5
import Media
import Multiparts
import Symbols
import URI
import UnixTime

extension Unidoc
{
    struct Router
    {
        let headers:HTTP.Headers
        let session:Unidoc.UserSession?
        let origin:IP.Origin
        let host:String?

        private
        var stem:ArraySlice<String>
        private
        let query:URI.Query

        private
        init(
            headers:HTTP.Headers,
            session:Unidoc.UserSession?,
            origin:IP.Origin,
            host:String?,
            stem:ArraySlice<String>,
            query:URI.Query)
        {
            self.headers = headers
            self.session = session
            self.origin = origin
            self.host = host
            self.stem = stem
            self.query = query
        }
    }
}
extension Unidoc.Router
{
    init(_ metadata:Unidoc.IntegralRequest.Metadata)
    {
        self.init(
            headers: metadata.headers,
            session: metadata.cookies.session,
            origin: metadata.origin,
            host: metadata.host,
            stem: metadata.path,
            query: metadata.uri.query ?? [:])
    }
}
extension Unidoc.Router
{
    private
    var contentType:ContentType?
    {
        let contentType:String?

        switch self.headers
        {
        case .http1_1(let headers): contentType = headers["content-type"].first
        case .http2(let headers):   contentType = headers["content-type"].first
        }

        guard
        let contentType:String,
        let contentType:ContentType = .init(contentType)
        else
        {
            return nil
        }

        return contentType
    }

    private
    var etag:MD5?
    {
        switch self.headers
        {
        case .http1_1(let headers): .init(header: headers["if-none-match"])
        case .http2(let headers):   .init(header: headers["if-none-match"])
        }
    }

    private
    var hostSupportsPublicAPI:Bool
    {
        switch self.host
        {
        case "api.swiftinit.org"?:   true
        case "localhost"?:           true
        default:                     false
        }
    }
}
extension Unidoc.Router
{
    mutating
    func descend() -> String?
    {
        self.stem.popFirst()
    }

    mutating
    func descend<Component>(into:Component.Type = Component.self) -> Component?
        where Component:RawRepresentable<String>
    {
        guard
        let next:String = self.descend()
        else
        {
            return nil
        }

        return .init(rawValue: next)
    }

    mutating
    func descend(
        into:Unidoc.VolumeSelector.Type = Unidoc.VolumeSelector.self) -> Unidoc.VolumeSelector?
    {
        guard
        let next:String = self.descend()
        else
        {
            return nil
        }

        return .init(next)
    }

    mutating
    func descend(
        into:Symbol.Package.Type = Symbol.Package.self) -> Symbol.Package?
    {
        guard
        let next:String = self.descend()
        else
        {
            return nil
        }

        return .init(next)
    }
}
extension Unidoc.Router
{
    mutating
    func get() -> Unidoc.IntegralRequest.Ordering?
    {
        guard let root:Unidoc.ServerRoot = self.descend()
        else
        {
            return .explainable(Unidoc.HomeEndpoint.init(query: .init(limit: 16)),
                    parameters: .init(self.query),
                    etag: self.etag)
        }

        switch root
        {
        case .account:      return self.account()
        case .admin:        return self.admin()
        case .api:          return nil // POST only
        case .asset:        return self.asset()
        case .auth:         return self.auth()
        case .blog:         return self.blog(module: "Articles")
        case .docc:         return self.docs()
        case .docs:         return self.docs()
        case .guides:       return self.docsLegacy()
        case .help:         return self.blog(module: "Help")
        case .hist:         return self.docs()
        case .hook:         return nil // POST only
        case .login:        return self.login()
        case .lunr:         return self.lunr()
        case .plugin:       return self.plugin()
        case .pdct:         return nil // Unimplemented.
        case .ptcl:         return self.ptcl()
        case .really:       return nil // POST only
        case .realm:        return self.realm()
        case .reference:    return self.docsLegacy()
        case .robots_txt:   return self.robots()
        case .sitemap_xml:  return self.sitemap()
        case .sitemaps:     return self.sitemaps()
        case .ssgc:         return self.ssgc()
        case .stats:        return self.stats()
        case .tags:         return self.tags()
        case .telescope:    return self.telescope()
        case .user:         return self.user()
        }
    }

    mutating
    func post(body:[UInt8]) -> Unidoc.IntegralRequest.Ordering?
    {
        switch self.contentType
        {
        case .media(.application(.json, charset: _))?:
            return self.post(json: .init(utf8: body[...]))

        case .media(.application(.x_www_form_urlencoded, charset: _))?:
            guard
            let form:URI.Query = try? .parse(parameters: body)
            else
            {
                return .syncError("Cannot parse URL-encoded form data\n")
            }

            return self.post(form: form)

        case .multipart(.form_data(boundary: let boundary?))?:
            guard
            let form:MultipartForm = try? .init(splitting: body, on: boundary)
            else
            {
                return .syncError("Cannot parse multipart form data\n")
            }

            return self.post(form: form)

        case let other?:
            return .syncError("Cannot POST content type '\(other)'\n")

        default:
            return .syncError("Cannot POST without a content type\n")
        }
    }

    private mutating
    func post(json:JSON) -> Unidoc.IntegralRequest.Ordering?
    {
        switch self.descend(into: Unidoc.ServerRoot.self)
        {
        case .hook?:    return self.hook(json: json)
        default:        return nil
        }
    }

    private mutating
    func post(form:URI.Query) -> Unidoc.IntegralRequest.Ordering?
    {
        switch self.descend(into: Unidoc.ServerRoot.self)
        {
        case .admin?:   return self.admin(form: form)
        case .api?:     return self.api(form: form)
        case .login?:   return self.login(form: form)
        case .really?:  return self.really(form: form)
        default:        return nil
        }
    }
    private mutating
    func post(form:MultipartForm) -> Unidoc.IntegralRequest.Ordering?
    {
        switch self.descend(into: Unidoc.ServerRoot.self)
        {
        case .admin?:   return self.admin(form: form)
        case .api?:     return self.api(form: form)
        default:        return nil
        }
    }
}
extension Unidoc.Router
{
    private
    func account() -> Unidoc.IntegralRequest.Ordering
    {
        guard
        let user:Unidoc.UserSession = self.session
        else
        {
            return .syncRedirect(.temporary("\(Unidoc.ServerRoot.login)"))
        }

        return .explainable(Unidoc.UserSettingsEndpoint.init(
                query: .init(session: user)),
            parameters: .init(self.query),
            etag: self.etag)
    }
}
extension Unidoc.Router
{
    private mutating
    func admin() -> Unidoc.IntegralRequest.Ordering?
    {
        guard let next:String = self.descend()
        else
        {
            return .actor(Unidoc.LoadDashboardOperation.master)
        }

        switch next
        {
        case Unidoc.AdminPage.Recode.name:
            if  let target:Unidoc.AdminPage.Recode.Target = self.descend()
            {
                return .syncResource(target)
            }
            else
            {
                return .syncResource(Unidoc.AdminPage.Recode.init())
            }

        case Unidoc.ReplicaSetPage.name:
            return .actor(Unidoc.LoadDashboardOperation.replicaSet)

        case Unidoc.CookiePage.name:
            return .actor(Unidoc.LoadDashboardOperation.cookie(scramble: false))

        case "robots":
            return .actor(Unidoc.TextEditorOperation.init(id: .robots_txt))

        default:
            return nil
        }
    }
    //  These are kind of a mess right now.
    private mutating
    func admin(form:URI.Query) -> Unidoc.IntegralRequest.Ordering?
    {
        guard case Unidoc.CookiePage.name? = self.descend() as String?
        else
        {
            return nil
        }

        return .actor(Unidoc.LoadDashboardOperation.cookie(scramble: true))
    }
    private mutating
    func admin(form:MultipartForm) -> Unidoc.IntegralRequest.Ordering?
    {
        guard let action:String = self.descend()
        else
        {
            return nil
        }

        if  action == Unidoc.AdminPage.Recode.name,
            let target:Unidoc.AdminPage.Recode.Target = self.descend()
        {
            return .actor(Unidoc.SiteConfigOperation.recode(target))
        }
        else
        {
            return nil
        }
    }
}
extension Unidoc.Router
{
    private mutating
    func api(form:URI.Query) -> Unidoc.IntegralRequest.Ordering?
    {
        guard
        let action:Unidoc.PostAction = self.descend()
        else
        {
            return nil
        }

        let form:[String: String] = form.parameters.reduce(into: [:])
        {
            $0[$1.key] = $1.value
        }

        switch action
        {
        case .build:
            if  let account:Unidoc.Account = self.session?.account,
                let build:Unidoc.PackageBuildOperation.Parameters = .init(from: form)
            {
                return .actor(Unidoc.PackageBuildOperation.init(
                    account: account,
                    build: build))
            }

        case .packageAlias:
            if  let package:String = form["package"],
                let package:Unidoc.Package = .init(package),
                let alias:String = form["alias"]
            {
                return .actor(Unidoc.PackageAliasOperation.init(
                    package: package,
                    alias: .init(alias)))
            }

        case .packageAlign:
            if  let package:String = form["package"],
                let package:Unidoc.Package = .init(package)
            {
                return .update(Unidoc.PackageAlignOperation.init(
                    package: package,
                    realm: form["realm"],
                    force: form["force"] == "true"))
            }

        case .packageConfig:
            if  let package:String = form["package"],
                let package:Unidoc.Package = .init(package),
                let update:Unidoc.PackageConfigOperation.Update = .init(from: form)
            {
                let endpoint:Unidoc.PackageConfigOperation = .init(
                    account: self.session?.account,
                    package: package,
                    update: update,
                    from: form["from"])

                return .actor(endpoint)
            }

        case .packageIndex:
            if  let account:Unidoc.Account = self.session?.account,
                let subject:Unidoc.PackageIndexOperation.Subject = .init(from: form)
            {
                return .actor(Unidoc.PackageIndexOperation.init(
                    account: account,
                    subject: subject))
            }

        case .telescope:
            if  let days:String = form["days"],
                let days:Int = .init(days)
            {
                return .actor(Unidoc.SiteConfigOperation.telescope(days: days))
            }

        case .uplinkAll:
            return .actor(Unidoc.LinkerOperation.init(queue: .all))

        case .uplink:
            if  let package:String = form["package"],
                let package:Unidoc.Package = .init(package),
                let version:String = form["version"],
                let version:Unidoc.Version = .init(version)
            {
                return .actor(Unidoc.LinkerOperation.init(
                    queue: .one(.init(package: package, version: version),
                        action: .uplinkRefresh),
                    from: form["from"]))
            }

        case .unlink:
            if  let package:String = form["package"],
                let package:Unidoc.Package = .init(package),
                let version:String = form["version"],
                let version:Unidoc.Version = .init(version)
            {
                return .actor(Unidoc.LinkerOperation.init(
                    queue: .one(.init(package: package, version: version),
                        action: .unlink),
                    from: form["from"]))
            }

        case .delete:
            if  let package:String = form["package"],
                let package:Unidoc.Package = .init(package),
                let version:String = form["version"],
                let version:Unidoc.Version = .init(version)
            {
                return .actor(Unidoc.LinkerOperation.init(
                    queue: .one(.init(package: package, version: version),
                        action: .delete),
                    from: form["from"]))
            }

        case .userConfig:
            if  let account:Unidoc.Account = self.session?.account,
                let update:Unidoc.UserConfigOperation.Update = .init(from: form)
            {
                return .actor(Unidoc.UserConfigOperation.init(
                    account: account,
                    update: update))
            }

        case .userSyncPermissions:
            return .actor(Unidoc.LoginOperation.init(flow: .sync))

        default:
            break
        }

        return nil
    }
    private mutating
    func api(form:MultipartForm) -> Unidoc.IntegralRequest.Ordering?
    {
        guard
        let action:Unidoc.PostAction = self.descend()
        else
        {
            return nil
        }

        switch action
        {
        case .robots_txt:
            guard
            let item:MultipartForm.Item = form.first(where: { $0.header.name == "text" })
            else
            {
                return .syncError("Cannot parse form data: missing field 'text'\n")
            }

            return .actor(Unidoc.TextUpdateOperation.init(text: .init(id: .robots_txt,
                text: .utf8(item.value))))

        default:
            return nil
        }
    }
}
extension Unidoc.Router
{
    private mutating
    func asset() -> Unidoc.IntegralRequest.Ordering?
    {
        guard
        let asset:Unidoc.Asset = self.descend()
        else
        {
            return nil
        }

        return .syncLoad(.init(asset, tag: self.etag))
    }
}
extension Unidoc.Router
{
    private mutating
    func auth() -> Unidoc.IntegralRequest.Ordering?
    {
        let parameters:AuthParameters = .init(self.query)

        switch self.descend()
        {
        case "github"?:
            if  let state:String = parameters.state,
                let code:String = parameters.code,
                let from:String = parameters.from,
                let flow:Unidoc.LoginFlow = parameters.flow
            {
                return .actor(Unidoc.AuthOperation.init(state: state,
                    code: code,
                    flow: flow,
                    from: from))
            }

        case "register"?:
            if  let token:String = parameters.token
            {
                return .actor(Unidoc.UserIndexOperation.init(token: token, flow: .sso))
            }

        case _:
            break
        }

        return nil
    }
}
extension Unidoc.Router
{
    private mutating
    func blog(module:String) -> Unidoc.IntegralRequest.Ordering?
    {
        guard let article:String = self.descend()
        else
        {
            return nil
        }

        return .explainable(Unidoc.BlogEndpoint.init(query: .init(
                volume: .init(package: "__swiftinit", version: "__max"),
                vertex: .init(path: [module, article], hash: nil))),
            parameters: .init(self.query),
            etag: self.etag)
    }

    private mutating
    func docs() -> Unidoc.IntegralRequest.Ordering?
    {
        guard
        let volume:Unidoc.VolumeSelector = self.descend().map(Unidoc.VolumeSelector.init)
        else
        {
            return nil
        }

        let parameters:Unidoc.PipelineParameters = .init(self.query)

        //  Special sitemap route.
        //  The '-' in the name means it will never collide with a decl.
        if  case nil = volume.version,
            case ["all-symbols"] = self.stem
        {
            return .explainable(Unidoc.SitemapEndpoint.init(query: .init(
                    package: volume.package)),
                parameters: parameters,
                etag: self.etag)
        }
        else
        {
            let shoot:Unidoc.Shoot = .init(path: self.stem, hash: parameters.hash)
            return .explainable(Unidoc.DocsEndpoint.init(query: .init(
                    volume: volume,
                    vertex: shoot)),
                parameters: parameters,
                etag: self.etag)
        }
    }
}
extension Unidoc.Router
{
    private mutating
    func hook(json:JSON) -> Unidoc.IntegralRequest.Ordering?
    {
        switch self.descend()
        {
        case "github"?:
            do
            {
                return .actor(try Unidoc.PackageWebhookOperation.init(json: json,
                    from: self.origin,
                    with: self.headers))
            }
            catch let error
            {
                return .syncError("Rejected webhook event: \(error)")
            }

        default:
            return nil
        }
    }
}
extension Unidoc.Router
{
    private
    func login() -> Unidoc.IntegralRequest.Ordering
    {
        .actor(Unidoc.LoginOperation.init(flow: .sso))
    }
    private
    func login(form:URI.Query) -> Unidoc.IntegralRequest.Ordering
    {
        if  let path:String = form.parameters.first?.value,
            let path:URI = .init(path)
        {
            return .actor(Unidoc.LoginOperation.init(flow: .sso, from: path))
        }
        else
        {
            return .syncError("Cannot parse login form data: missing return path\n")
        }
    }
}
extension Unidoc.Router
{
    private mutating
    func lunr() -> Unidoc.IntegralRequest.Ordering?
    {
        guard let next:String = self.descend()
        else
        {
            return nil
        }

        let etag:MD5? = self.etag

        if  let id:Symbol.Edition = .init(next)
        {
            return .explainable(Unidoc.LunrEndpoint.init(query: .init(tag: etag, id: id)),
                parameters: .init(self.query),
                etag: etag)
        }
        else if next == "packages.json"
        {
            return .explainable(Unidoc.TextEndpoint.init(query: .init(tag: etag,
                    id: .packages_json)),
                parameters: .init(self.query),
                etag: etag)
        }
        else
        {
            return nil
        }
    }
}
extension Unidoc.Router
{
    private mutating
    func plugin() -> Unidoc.IntegralRequest.Ordering?
    {
        guard let next:String = self.descend()
        else
        {
            return nil
        }

        return .actor(Unidoc.LoadDashboardOperation.plugin(next))
    }

    private mutating
    func ptcl() -> Unidoc.IntegralRequest.Ordering?
    {
        guard
        let volume:Unidoc.VolumeSelector = self.descend()
        else
        {
            return nil
        }

        let parameters:Unidoc.PipelineParameters = .init(self.query)

        return .explainable(Unidoc.PtclEndpoint.init(query: .init(
                volume: volume,
                vertex: .init(path: self.stem, hash: parameters.hash),
                layer: .protocols)),
            parameters: parameters,
            etag: self.etag)
    }

    private mutating
    func realm() -> Unidoc.IntegralRequest.Ordering?
    {
        guard
        let realm:String = self.descend()
        else
        {
            return nil
        }

        return .explainable(Unidoc.RealmEndpoint.init(query: .init(realm: realm,
                user: self.session?.account)),
            parameters: .init(self.query),
            etag: self.etag)
    }

    private mutating
    func render() -> Unidoc.IntegralRequest.Ordering?
    {
        guard self.hostSupportsPublicAPI
        else
        {
            return .syncRedirect(.permanent(external: "https://api.swiftinit.org/render"))
        }

        guard
        let volume:Unidoc.VolumeSelector = self.descend()
        else
        {
            return nil
        }

        return .actor(Unidoc.UserRenderOperation.init(volume: volume,
            shoot: .init(path: self.stem),
            query: self.query))
    }
}
extension Unidoc.Router
{
    private mutating
    func really(form:URI.Query) -> Unidoc.IntegralRequest.Ordering?
    {
        guard
        let confirm:Unidoc.PostAction = self.descend()
        else
        {
            return nil
        }

        let action:URI = .init(path: Unidoc.Post[confirm].path, query: form)
        var table:[String: String]
        {
            form.parameters.reduce(into: [:]) { $0[$1.key] = $1.value }
        }

        let really:Unidoc.ReallyPage?

        switch confirm
        {
        case .build:
            guard
            let build:Unidoc.PackageBuildOperation.Parameters = .init(from: table)
            else
            {
                return nil
            }

            return .syncResource(Unidoc.BuildRequestPage.init(selector: build.selector,
                cancel: build.request == nil,
                action: action))

        case .unlink:
            really = .unlink(action)

        case .delete:
            really = .delete(action)

        case .packageConfig:
            guard
            let update:Unidoc.PackageConfigOperation.Update = .init(from: table)
            else
            {
                return nil
            }

            really = .packageConfig(action, update: update)

        case .userConfig:
            guard
            let update:Unidoc.UserConfigOperation.Update = .init(from: table)
            else
            {
                return nil
            }

            really =  .userConfig(action, update: update)

        default:
            return nil
        }

        guard
        let really:Unidoc.ReallyPage = really
        else
        {
            return nil
        }

        return .syncResource(really)
    }
}
extension Unidoc.Router
{
    private
    func robots() -> Unidoc.IntegralRequest.Ordering
    {
        let etag:MD5? = self.etag
        return .explainable(Unidoc.TextEndpoint.init(query: .init(
                tag: etag,
                id: .robots_txt)),
            parameters: .init(self.query),
            etag: etag)
    }

    private
    func sitemap() -> Unidoc.IntegralRequest.Ordering
    {
        .actor(Unidoc.LoadSitemapIndexOperation.init(tag: self.etag))
    }

    /// Deprecated route.
    private mutating
    func sitemaps() -> Unidoc.IntegralRequest.Ordering?
    {
        guard let next:String = self.descend()
        else
        {
            return nil
        }

        return .syncRedirect(.permanent("""
            \(Unidoc.ServerRoot.docs)/\(next.prefix { $0 != "." })/all-symbols
            """))
    }

    private mutating
    func ssgc() -> Unidoc.IntegralRequest.Ordering?
    {
        switch self.descend()
        {
        case nil:
            guard let build:Unidoc.BuildLabelsPrompt = .init(query: self.query)
            else
            {
                return nil
            }

            return .actor(Unidoc.BuilderLabelOperation.init(prompt: build))

        case "poll"?:
            guard let user:Unidoc.UserSession = self.session
            else
            {
                return nil
            }

            return .actor(Unidoc.BuilderPollOperation.init(id: user.account))

        default:
            return nil
        }
    }

    private mutating
    func stats() -> Unidoc.IntegralRequest.Ordering?
    {
        guard let volume:Unidoc.VolumeSelector = self.descend()
        else
        {
            return nil
        }

        let parameters:Unidoc.PipelineParameters = .init(self.query)

        return .explainable(Unidoc.StatsEndpoint.init(query: .init(
                volume: volume,
                vertex: .init(path: self.stem, hash: parameters.hash))),
            parameters: parameters,
            etag: self.etag)
    }

    private mutating
    func tags() -> Unidoc.IntegralRequest.Ordering?
    {
        guard let symbol:Symbol.Package = self.descend()
        else
        {
            return nil
        }

        let parameters:Unidoc.PipelineParameters = .init(self.query)

        let filter:Unidoc.VersionsQuery.Predicate

        if  let page:Int = parameters.page
        {
            filter = .tags(limit: 20,
                page: page,
                series: parameters.beta ? .prerelease : .release)
        }
        else
        {
            filter = .none(limit: 12)
        }

        return .explainable(Unidoc.TagsEndpoint.init(query: .init(
                symbol: symbol,
                filter: filter,
                as: self.session?.account)),
            parameters: parameters,
            etag: self.etag)
    }

    private mutating
    func telescope() -> Unidoc.IntegralRequest.Ordering?
    {
        guard let next:String = self.descend()
        else
        {
            return nil
        }

        if  let year:Timestamp.Year = .init(next),
            let endpoint:Unidoc.PackagesCrawledEndpoint = .init(year: year)
        {
            return .explainable(endpoint, parameters: .init(self.query), etag: self.etag)
        }
        else if
            let date:Timestamp.Date = .init(next),
            let endpoint:Unidoc.PackagesCreatedEndpoint = .init(date: date)
        {
            return .explainable(endpoint, parameters: .init(self.query), etag: self.etag)
        }
        else
        {
            return nil
        }
    }

    private mutating
    func user() -> Unidoc.IntegralRequest.Ordering?
    {
        guard
        let account:String = self.descend(),
        let account:Unidoc.Account = .init(account)
        else
        {
            return nil
        }

        return .explainable(Unidoc.UserPropertyEndpoint.init(query: .init(
                account: account)),
            parameters: .init(self.query),
            etag: self.etag)
    }

    private mutating
    func docsLegacy() -> Unidoc.IntegralRequest.Ordering?
    {
        guard let next:String = self.descend()
        else
        {
            return nil
        }

        let parameters:LegacyParameters = .init(self.query)

        let query:Unidoc.RedirectQuery<Unidoc.Shoot> = .legacy(head: next,
            rest: self.stem,
            from: parameters.from)

        //  Always pass empty parameters, as this endpoint always returns a redirect!
        if  let overload:Symbol.Decl = parameters.overload
        {
            return .explainable(Unidoc.RedirectEndpoint<Symbol.Decl>.init(
                    query: .init(volume: query.volume, lookup: overload)),
                parameters: .none,
                etag: self.etag)
        }
        else
        {
            return .explainable(Unidoc.RedirectEndpoint<Unidoc.Shoot>.init(
                    query: query),
                parameters: .none,
                etag: self.etag)
        }
    }
}

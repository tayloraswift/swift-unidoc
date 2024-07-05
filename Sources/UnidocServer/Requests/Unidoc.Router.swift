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
        let authorization:Authorization
        let origin:IP.Origin
        let host:String?

        private
        var stem:ArraySlice<String>
        private
        let query:URI.Query

        private
        init(
            headers:HTTP.Headers,
            authorization:Authorization,
            origin:IP.Origin,
            host:String?,
            stem:ArraySlice<String>,
            query:URI.Query)
        {
            self.headers = headers
            self.authorization = authorization
            self.origin = origin
            self.host = host
            self.stem = stem
            self.query = query
        }
    }
}
extension Unidoc.Router
{
    init(routing request:Unidoc.IncomingRequest)
    {
        self.init(
            headers: request.headers,
            authorization: request.authorization,
            origin: request.origin.ip,
            host: request.host,
            stem: request.path,
            query: request.uri.query ?? [:])
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
    private
    func redirect(root:Unidoc.ServerRoot) -> String?
    {
        let subdomain:Unidoc.ServerRoot.Subdomain?
        switch self.host
        {
        case "swiftinit.org"?:
            switch root.subdomain
            {
            case nil:           return nil
            case let target?:   subdomain = target
            }

        case "api.swiftinit.org"?:
            switch root.subdomain
            {
            case .api?:         return nil
            case let target:    subdomain = target
            }

        default:
            return nil
        }

        var path:URI.Path = root.path
        for component:String in self.stem
        {
            path.append(component)
        }

        let uri:URI = .init(path: path, query: self.query)

        if  let subdomain:Unidoc.ServerRoot.Subdomain
        {
            return "https://\(subdomain).swiftinit.org\(uri)"
        }
        else
        {
            return "https://swiftinit.org\(uri)"
        }
    }
}
extension Unidoc.Router
{
    mutating
    func get() -> Unidoc.AnyOperation?
    {
        guard
        let root:String = self.descend()
        else
        {
            return .explainable(Unidoc.HomeEndpoint.init(query: .init(limit: 16)),
                    parameters: .init(self.query),
                    etag: self.etag)
        }

        guard
        let root:Unidoc.ServerRoot = .init(rawValue: root)
        else
        {
            return nil
        }

        if  let redirect:String = self.redirect(root: root)
        {
            return .sync(redirect: .permanent(external: redirect))
        }

        switch root
        {
        case .account:      return self.account()
        case .admin:        return self.admin()
        case .asset:        return self.asset()
        case .auth:         return self.auth()
        case .blog:         return self.blog(module: "Articles")
        case .builder:      return self.builder()
        case .consumers:    return self.consumers()
        case .docc:         return self.docs()
        case .docs:         return self.docs()
        case .form:         return nil // POST only
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
        case .ref:          return self.ref(form: nil)
        case .render:       return self.render()
        case .robots_txt:   return self.robots()
        case .rules:        return self.rules()
        case .sitemap_xml:  return self.sitemap()
        case .sitemaps:     return self.sitemaps()
        case .stats:        return self.stats()
        case .tags:         return self.tags()
        case .telescope:    return self.telescope()
        case .user:         return self.user()
        }
    }

    mutating
    func post(body:[UInt8]) -> Unidoc.AnyOperation?
    {
        guard
        let root:Unidoc.ServerRoot = self.descend()
        else
        {
            return nil
        }

        if  let redirect:String = self.redirect(root: root)
        {
            return .sync(redirect: .permanent(external: redirect))
        }

        switch self.contentType
        {
        case .media(.application(.json, charset: _))?:
            return self.post(root: root, json: .init(utf8: body[...]))

        case .media(.application(.x_www_form_urlencoded, charset: _))?:
            guard
            let form:URI.Query = try? .parse(parameters: body)
            else
            {
                return .sync(error: "Cannot parse URL-encoded form data\n")
            }

            return self.post(root: root, form: form)

        case .multipart(.form_data(boundary: let boundary?))?:
            guard
            let form:MultipartForm = try? .init(splitting: body, on: boundary)
            else
            {
                return .sync(error: "Cannot parse multipart form data\n")
            }

            return self.post(root: root, form: form)

        case let other?:
            return .sync(error: "Cannot POST content type '\(other)'\n")

        default:
            return .sync(error: "Cannot POST without a content type\n")
        }
    }

    private mutating
    func post(root:Unidoc.ServerRoot, json:JSON) -> Unidoc.AnyOperation?
    {
        switch root
        {
        case .hook:     return self.hook(json: json)
        default:        return nil
        }
    }
    private mutating
    func post(root:Unidoc.ServerRoot, form:URI.Query) -> Unidoc.AnyOperation?
    {
        switch root
        {
        case .admin:    return nil
        case .form:     return self.form(form: form)
        case .login:    return self.login(form: form)
        case .really:   return self.really(form: form)
        case .ref:      return self.ref(form: form)
        default:        return nil
        }
    }
    private mutating
    func post(root:Unidoc.ServerRoot, form:MultipartForm) -> Unidoc.AnyOperation?
    {
        switch root
        {
        case .admin:    return self.admin(form: form)
        case .form:     return self.form(form: form)
        default:        return nil
        }
    }
}
extension Unidoc.Router
{
    private mutating
    func account() -> Unidoc.AnyOperation
    {
        if  let account:String = self.descend(),
            let account:Unidoc.Account = .init(account)
        {
            return .unordered(Unidoc.UserAdminOperation.init(account: account))
        }
        else
        {
            guard case .web(let session?, _) = self.authorization
            else
            {
                return .sync(redirect: .temporary("\(Unidoc.ServerRoot.login)"))
            }

            return .explainable(Unidoc.UserSettingsEndpoint.init(query: .current(session)),
                parameters: .init(self.query),
                etag: self.etag)
        }
    }
}
extension Unidoc.Router
{
    private mutating
    func admin() -> Unidoc.AnyOperation?
    {
        guard let next:String = self.descend()
        else
        {
            return .unordered(Unidoc.LoadDashboardOperation.logger)
        }

        switch next
        {
        case Unidoc._RecodePage.name:
            if  let target:Unidoc._RecodePage.Target = self.descend()
            {
                return .syncHTML(target)
            }
            else
            {
                return .syncHTML(Unidoc._RecodePage.init())
            }

        case Unidoc.ReplicaSetPage.name:
            return .unordered(Unidoc.LoadDashboardOperation.replicaSet)

        case "robots":
            return .unordered(Unidoc.TextEditorOperation.init(id: .robots_txt))

        default:
            return nil
        }
    }

    private mutating
    func admin(form:MultipartForm) -> Unidoc.AnyOperation?
    {
        guard let action:String = self.descend()
        else
        {
            return nil
        }

        if  action == Unidoc._RecodePage.name,
            let target:Unidoc._RecodePage.Target = self.descend()
        {
            return .unordered(Unidoc.SiteConfigOperation.recode(target))
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
    func builder() -> Unidoc.AnyOperation?
    {
        switch self.descend()
        {
        case nil:
            guard let build:Unidoc.BuildLabelsPrompt = .init(query: self.query)
            else
            {
                return nil
            }

            return .unordered(Unidoc.BuilderLabelOperation.init(prompt: build))

        case "poll"?:
            guard let account:Unidoc.Account = self.authorization.account
            else
            {
                return .sync(error: "Missing authorization header\n", status: 401)
            }

            return .unordered(Unidoc.BuilderPollOperation.init(id: account))

        default:
            return nil
        }
    }

    private mutating
    func form(form:URI.Query) -> Unidoc.AnyOperation?
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
            if  let account:Unidoc.Account = self.authorization.account,
                let build:Unidoc.PackageBuildOperation.DirectParameters = .init(from: form)
            {
                return .unordered(Unidoc.PackageBuildOperation.init(
                    account: account,
                    build: build))
            }

        case .packageAlias:
            if  let package:String = form["package"],
                let package:Unidoc.Package = .init(package),
                let alias:String = form["alias"]
            {
                return .unordered(Unidoc.PackageAliasOperation.init(
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
                    account: self.authorization.account,
                    package: package,
                    update: update,
                    from: form["from"])

                return .unordered(endpoint)
            }

        case .packageIndex:
            if  let account:Unidoc.Account = self.authorization.account,
                let subject:Unidoc.PackageIndexOperation.Subject = .init(from: form)
            {
                return .unordered(Unidoc.PackageIndexOperation.init(
                    account: account,
                    subject: subject))
            }

        case .packageRules:
            if  let account:Unidoc.Account = self.authorization.account,
                let package:String = form["package"],
                let package:Unidoc.Package = .init(package),
                let rule:Unidoc.UpdatePackageRule = .init(from: form)
            {
                return .unordered(Unidoc.UpdatePackageRuleOperation.init(
                    account: account,
                    package: package,
                    rule: rule))
            }

        case .telescope:
            if  let days:String = form["days"],
                let days:Int = .init(days)
            {
                return .unordered(Unidoc.SiteConfigOperation.telescope(days: days))
            }

        case .uplinkAll:
            return .unordered(Unidoc.LinkerOperation.init(queue: .all))

        case .uplink:
            if  let package:String = form["package"],
                let package:Unidoc.Package = .init(package),
                let version:String = form["version"],
                let version:Unidoc.Version = .init(version)
            {
                return .unordered(Unidoc.LinkerOperation.init(
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
                return .unordered(Unidoc.LinkerOperation.init(
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
                return .unordered(Unidoc.LinkerOperation.init(
                    queue: .one(.init(package: package, version: version),
                        action: .delete),
                    from: form["from"]))
            }

        case .userConfig:
            if  let account:Unidoc.Account = self.authorization.account,
                let update:Unidoc.UserConfigOperation.Update = .init(from: form)
            {
                return .unordered(Unidoc.UserConfigOperation.init(
                    account: account,
                    update: update))
            }

        case .userSyncPermissions:
            return .unordered(Unidoc.LoginOperation.init(flow: .sync))

        default:
            break
        }

        return nil
    }
    private mutating
    func form(form:MultipartForm) -> Unidoc.AnyOperation?
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
                return .sync(error: "Cannot parse form data: missing field 'text'\n")
            }

            return .unordered(Unidoc.TextUpdateOperation.init(text: .init(id: .robots_txt,
                text: .utf8(item.value))))

        default:
            return nil
        }
    }
}
extension Unidoc.Router
{
    private mutating
    func asset() -> Unidoc.AnyOperation?
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
    func auth() -> Unidoc.AnyOperation?
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
                return .unordered(Unidoc.AuthOperation.init(state: state,
                    code: code,
                    flow: flow,
                    from: from))
            }

        case "register"?:
            if  let token:String = parameters.token
            {
                return .unordered(Unidoc.UserIndexOperation.init(token: token, flow: .sso))
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
    func blog(module:String) -> Unidoc.AnyOperation?
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
    func docs() -> Unidoc.AnyOperation?
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
    func hook(json:JSON) -> Unidoc.AnyOperation?
    {
        switch self.descend()
        {
        case "github"?:
            do
            {
                return .unordered(try Unidoc.PackageWebhookOperation.init(json: json,
                    from: self.origin,
                    with: self.headers))
            }
            catch let error
            {
                //  This is considered a server error, so we want to flag it as such for the
                //  logging system to pick up.
                return .sync(error: "Rejected webhook event: \(error)", status: 500)
            }

        default:
            return nil
        }
    }
}
extension Unidoc.Router
{
    private
    func login() -> Unidoc.AnyOperation
    {
        .unordered(Unidoc.LoginOperation.init(flow: .sso))
    }
    private
    func login(form:URI.Query) -> Unidoc.AnyOperation
    {
        if  let path:String = form.parameters.first?.value,
            let path:URI = .init(path)
        {
            return .unordered(Unidoc.LoginOperation.init(flow: .sso, from: path))
        }
        else
        {
            return .sync(error: "Cannot parse login form data: missing return path\n")
        }
    }
}
extension Unidoc.Router
{
    private mutating
    func lunr() -> Unidoc.AnyOperation?
    {
        guard let next:String = self.descend()
        else
        {
            return nil
        }

        let etag:MD5? = self.etag

        if  let id:Symbol.Volume = .init(next)
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
    func plugin() -> Unidoc.AnyOperation?
    {
        guard let next:String = self.descend()
        else
        {
            return nil
        }

        return .unordered(Unidoc.LoadDashboardOperation.plugin(next))
    }

    private mutating
    func ptcl() -> Unidoc.AnyOperation?
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
    func realm() -> Unidoc.AnyOperation?
    {
        guard
        let realm:String = self.descend()
        else
        {
            return nil
        }

        return .explainable(Unidoc.RealmEndpoint.init(query: .init(realm: realm,
                user: self.authorization.account)),
            parameters: .init(self.query),
            etag: self.etag)
    }

    private mutating
    func ref(form:URI.Query?) -> Unidoc.AnyOperation?
    {
        guard
        let symbol:Symbol.Package = self.descend(),
        let name:String = self.descend()
        else
        {
            return nil
        }

        guard let next:String = self.descend()
        else
        {
            return nil
        }

        switch next
        {
        case "build":
            guard
            let account:Unidoc.Account = self.authorization.account
            else
            {
                return nil
            }

            return .unordered(Unidoc.PackageBuildOperation.init(account: account,
                action: .submitSymbolic(.init(package: symbol, ref: name)),
                redirect: symbol))

        case "state":
            return .unordered(Unidoc.LoadEditionStateOperation.init(
                authorization: self.authorization,
                package: symbol,
                version: .name(name)))

        default:
            return nil
        }
    }

    private mutating
    func render() -> Unidoc.AnyOperation?
    {
        guard
        let volume:Unidoc.VolumeSelector = self.descend()
        else
        {
            return nil
        }

        return .unordered(Unidoc.ExportOperation.init(authorization: self.authorization,
            request: .init(volume: volume, vertex: .init(path: self.stem)),
            _query: self.query))
    }
}
extension Unidoc.Router
{
    private mutating
    func really(form:URI.Query) -> Unidoc.AnyOperation?
    {
        guard
        let action:Unidoc.PostAction = self.descend()
        else
        {
            return nil
        }

        let uri:URI = .init(path: Unidoc.Post[action].path, query: form)
        var table:[String: String]
        {
            form.parameters.reduce(into: [:]) { $0[$1.key] = $1.value }
        }

        let really:Unidoc.ReallyPage?

        switch action
        {
        case .build:
            guard
            let build:Unidoc.PackageBuildOperation.DirectParameters = .init(from: table)
            else
            {
                return nil
            }

            return .syncHTML(Unidoc.BuildRequestPage.init(selector: build.selector,
                cancel: build.request == nil,
                action: uri))

        case .unlink:
            really = .unlink(uri)

        case .delete:
            really = .delete(uri)

        case .packageConfig:
            guard
            let update:Unidoc.PackageConfigOperation.Update = .init(from: table)
            else
            {
                return nil
            }

            really = .packageConfig(uri, update: update)

        case .userConfig:
            guard
            let update:Unidoc.UserConfigOperation.Update = .init(from: table)
            else
            {
                return nil
            }

            really =  .userConfig(uri, update: update)

        default:
            return nil
        }

        guard
        let really:Unidoc.ReallyPage = really
        else
        {
            return nil
        }

        return .syncHTML(really)
    }
}
extension Unidoc.Router
{
    private
    func robots() -> Unidoc.AnyOperation
    {
        let etag:MD5? = self.etag
        return .explainable(Unidoc.TextEndpoint.init(query: .init(
                tag: etag,
                id: .robots_txt)),
            parameters: .init(self.query),
            etag: etag)
    }

    private mutating
    func rules() -> Unidoc.AnyOperation?
    {
        guard let symbol:Symbol.Package = self.descend()
        else
        {
            return nil
        }

        let parameters:Unidoc.PipelineParameters = .init(self.query)

        return .explainable(Unidoc.RulesEndpoint.init(query: .init(symbol: symbol,
                as: self.authorization.account)),
            parameters: parameters,
            etag: self.etag)
    }

    private
    func sitemap() -> Unidoc.AnyOperation
    {
        .unordered(Unidoc.LoadSitemapIndexOperation.init(tag: self.etag))
    }

    /// Deprecated route.
    private mutating
    func sitemaps() -> Unidoc.AnyOperation?
    {
        guard let next:String = self.descend()
        else
        {
            return nil
        }

        return .sync(redirect: .permanent("""
            \(Unidoc.ServerRoot.docs)/\(next.prefix { $0 != "." })/all-symbols
            """))
    }

    private mutating
    func stats() -> Unidoc.AnyOperation?
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
    func tags() -> Unidoc.AnyOperation?
    {
        guard let symbol:Symbol.Package = self.descend()
        else
        {
            return nil
        }

        let parameters:Unidoc.PipelineParameters = .init(self.query)

        if  let page:Int = parameters.page
        {
            return .explainable(Unidoc.TagsEndpoint.init(query: .init(
                    symbol: symbol,
                    filter: parameters.beta ? .prerelease : .release,
                    limit: 20,
                    page: page,
                    as: self.authorization.account)),
                parameters: parameters,
                etag: self.etag)
        }
        else
        {
            return .explainable(Unidoc.RefsEndpoint.init(query: .init(
                    symbol: symbol,
                    limitTags: 12,
                    limitBranches: 32,
                    limitDependents: 16,
                    as: self.authorization.account)),
                parameters: parameters,
                etag: self.etag)
        }
    }

    private mutating
    func consumers() -> Unidoc.AnyOperation?
    {
        guard let symbol:Symbol.Package = self.descend()
        else
        {
            return nil
        }

        let parameters:Unidoc.PipelineParameters = .init(self.query)
        return .explainable(Unidoc.ConsumersEndpoint.init(query: .init(
                symbol: symbol,
                limit: 20,
                page: parameters.page ?? 0,
                as: self.authorization.account)),
            parameters: parameters,
            etag: self.etag)
    }

    private mutating
    func telescope() -> Unidoc.AnyOperation?
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
    func user() -> Unidoc.AnyOperation?
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
    func docsLegacy() -> Unidoc.AnyOperation?
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

import BSON
import FNV1
import HTTP
import MD5
import Media
import MongoDB
import Multiparts
import SemanticVersions
import SwiftinitPages
import Symbols
import UnidocDB
import UnidocQueries
import UnidocRecords
import UnixTime
import URI

extension Swiftinit.IntegralRequest
{
    enum Ordering:Sendable
    {
        /// Runs directly on the actor, which provides no ordering guarantees. Suspensions while
        /// serving the request might interleave with other requests.
        case actor(any Swiftinit.InteractiveEndpoint)
        /// Runs on the update loop, which is ordered with respect to other updates.
        case update(any Swiftinit.ProceduralEndpoint)

        case syncResource(any Swiftinit.RenderablePage & Sendable)
        case syncRedirect(HTTP.Redirect)
        case syncLoad(Cache<Swiftinit.Asset>.Request)
    }
}
extension Swiftinit.IntegralRequest.Ordering
{
    static
    func explainable<Base>(_ endpoint:Base,
        parameters:Swiftinit.PipelineParameters,
        accept:HTTP.AcceptType? = nil) -> Self
        where   Base:HTTP.ServerEndpoint<Swiftinit.RenderFormat>,
                Base:Mongo.PipelineEndpoint,
                Base:Sendable
    {
        parameters.explain
        ? .actor(Swiftinit.ExplanatoryEndpoint<Base.Query>.init(query: endpoint.query))
        : .actor(Swiftinit.OptimizingEndpoint<Base>.init(base: endpoint,
            etag: parameters.tag))
    }
}
//  GET endpoints
extension Swiftinit.IntegralRequest.Ordering
{
    static
    func get(admin trunk:String, _ stem:ArraySlice<String>, tag:MD5?) -> Self?
    {
        if  let action:Swiftinit.AdminPage.Action = .init(rawValue: trunk)
        {
            return .syncResource(action)
        }

        switch trunk
        {
        case Swiftinit.AdminPage.Recode.name:
            guard
            let target:String = stem.first
            else
            {
                return .syncResource(Swiftinit.AdminPage.Recode.init())
            }

            if  let target:Swiftinit.AdminPage.Recode.Target = .init(rawValue: target)
            {
                return .syncResource(target)
            }
            else
            {
                return nil
            }

        case Swiftinit.ReplicaSetPage.name:
            return .actor(Swiftinit.DashboardEndpoint.replicaSet)

        case Swiftinit.CookiePage.name:
            return .actor(Swiftinit.DashboardEndpoint.cookie(scramble: false))

        case "robots":
            return .actor(Swiftinit.TextEditorEndpoint.init(id: .robots_txt))

        case _:
            return nil
        }
    }

    static
    func get(asset trunk:String, tag:MD5?) -> Self?
    {
        let asset:Swiftinit.Asset? = .init(trunk)
        return asset.map { .syncLoad(.init($0, tag: tag)) }
    }

    static
    func get(auth trunk:String, with parameters:Swiftinit.AuthParameters) -> Self?
    {
        switch trunk
        {
        case "github":
            if  let state:String = parameters.state,
                let code:String = parameters.code,
                let from:String = parameters.from
            {
                return .actor(Swiftinit.AuthEndpoint.init(state: state,
                    code: code,
                    from: from))
            }

        case "register":
            if  let token:String = parameters.token
            {
                return .actor(Swiftinit.RegistrationEndpoint.init(token: token))
            }

        case _:
            break
        }

        return nil
    }

    static
    func get(blog:String,
        _ trunk:String,
        with parameters:Swiftinit.PipelineParameters) -> Self
    {
        .explainable(Swiftinit.BlogEndpoint.init(query: .init(
                volume: .init(package: "__swiftinit", version: "__max"),
                vertex: .init(path: [blog, trunk], hash: nil))),
            parameters: parameters)
    }

    static
    func get(docs trunk:String,
        _ stem:ArraySlice<String>,
        with parameters:Swiftinit.PipelineParameters) -> Self
    {
        let volume:Unidoc.VolumeSelector = .init(trunk)

        //  Special sitemap route.
        //  The '-' in the name means it will never collide with a decl.
        if  case nil = volume.version,
            case "all-symbols"? = stem.first,
            case stem.endIndex = stem.index(after: stem.startIndex)
        {
            return .explainable(Swiftinit.SitemapEndpoint.init(query: .init(
                    package: volume.package)),
                parameters: parameters)
        }
        else
        {
            let shoot:Unidoc.Shoot = .init(path: stem, hash: parameters.hash)
            return .explainable(Swiftinit.DocsEndpoint.init(query: .init(
                    volume: volume,
                    vertex: shoot)),
                parameters: parameters)
        }
    }

    static
    func get(lunr trunk:String,
        with parameters:Swiftinit.PipelineParameters) -> Self?
    {
        if  let id:Symbol.Edition = .init(trunk)
        {
            .explainable(Swiftinit.LunrEndpoint.init(query: .init(
                    tag: parameters.tag,
                    id: id)),
                parameters: parameters,
                accept: .application(.json))
        }
        else if trunk == "packages.json"
        {
            .explainable(Swiftinit.TextEndpoint.init(query: .init(
                    tag: parameters.tag,
                    id: .packages_json)),
                parameters: parameters,
                accept: .application(.json))
        }
        else
        {
            nil
        }
    }

    static
    func get(ptcl trunk:String,
        _ stem:ArraySlice<String>,
        with parameters:Swiftinit.PipelineParameters) -> Self
    {
        .explainable(Swiftinit.PtclEndpoint.init(query: .init(
                volume: .init(trunk),
                vertex: .init(path: stem, hash: parameters.hash),
                layer: .protocols)),
            parameters: parameters)
    }

    static
    func get(realm trunk:String,
        with parameters:Swiftinit.PipelineParameters) -> Self
    {
        .explainable(Swiftinit.RealmEndpoint.init(query: .init(
                realm: trunk,
                user: parameters.user)),
            parameters: parameters)
    }

    static
    func get(stats trunk:String,
        _ stem:ArraySlice<String>,
        with parameters:Swiftinit.PipelineParameters) -> Self
    {
        .explainable(Swiftinit.StatsEndpoint.init(query: .init(
                volume: .init(trunk),
                vertex: .init(path: stem, hash: parameters.hash))),
            parameters: parameters)
    }

    static
    func get(tags trunk:String, with parameters:Swiftinit.PipelineParameters) -> Self
    {
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

        return .explainable(Swiftinit.TagsEndpoint.init(query: .init(
                symbol: .init(trunk),
                filter: filter,
                as: parameters.user)),
            parameters: parameters)
    }

    static
    func get(telescope trunk:String, with parameters:Swiftinit.PipelineParameters) -> Self?
    {
        if  let year:Timestamp.Year = .init(trunk),
            let endpoint:Swiftinit.PackagesCrawledEndpoint = .init(year: year)
        {
            .explainable(endpoint, parameters: parameters)
        }
        else if
            let date:Timestamp.Date = .init(trunk),
            let endpoint:Swiftinit.PackagesCreatedEndpoint = .init(date: date)
        {
            .explainable(endpoint, parameters: parameters)
        }
        else
        {
            nil
        }
    }

    static
    func get(
        legacy trunk:String,
        _ stem:ArraySlice<String>,
        with parameters:Swiftinit.LegacyParameters) -> Self
    {
        let query:Unidoc.RedirectQuery<Unidoc.Shoot> = .legacy(head: trunk,
            rest: stem,
            from: parameters.from)

        //  Always pass empty parameters, as this endpoint always returns a redirect!
        if  let overload:Symbol.Decl = parameters.overload
        {
            return .explainable(Swiftinit.RedirectEndpoint<Symbol.Decl>.init(
                    query: .init(volume: query.volume, lookup: overload)),
                parameters: .none)
        }
        else
        {
            return .explainable(Swiftinit.RedirectEndpoint<Unidoc.Shoot>.init(
                    query: query),
                parameters: .none)
        }
    }
}

//  POST endpoints
extension Swiftinit.IntegralRequest.Ordering
{
    static
    func post(admin action:String, _ rest:ArraySlice<String>,
        body:consuming [UInt8],
        type:ContentType) throws -> Self?
    {
        if  let action:Swiftinit.AdminPage.Action = .init(rawValue: action),
            case  .multipart(.form_data(boundary: let boundary?)) = type
        {
            let form:MultipartForm = try .init(splitting: body, on: boundary)
            return .actor(Swiftinit.SiteConfigEndpoint.perform(action, form))
        }

        switch action
        {
        case Swiftinit.AdminPage.Recode.name:
            if  let target:String = rest.first,
                let target:Swiftinit.AdminPage.Recode.Target = .init(rawValue: target)
            {
                return .actor(Swiftinit.SiteConfigEndpoint.recode(target))
            }

        case Swiftinit.CookiePage.name:
            return .actor(Swiftinit.DashboardEndpoint.cookie(scramble: true))

        case _:
            break
        }

        return nil
    }

    static
    func post(api trunk:String,
        body:consuming [UInt8],
        type:ContentType,
        user account:Unidoc.Account?) throws -> Self?
    {
        guard
        let trunk:Swiftinit.API.Post = .init(trunk)
        else
        {
            return nil
        }

        switch type
        {
        case .media(.application(.x_www_form_urlencoded, charset: _)):
            let query:URI.Query = try .parse(parameters: body)
            let form:[String: String] = query.parameters.reduce(into: [:])
            {
                $0[$1.key] = $1.value
            }

            switch trunk
            {
            case .packageAlias:
                if  let package:String = form["package"],
                    let package:Unidoc.Package = .init(package),
                    let alias:String = form["alias"]
                {
                    return .actor(Swiftinit.PackageAliasEndpoint.init(
                        package: package,
                        alias: .init(alias)))
                }

            case .packageAlign:
                if  let package:String = form["package"],
                    let package:Unidoc.Package = .init(package)
                {
                    return .update(Swiftinit.PackageAlignEndpoint.init(
                        package: package,
                        realm: form["realm"],
                        force: form["force"] == "true"))
                }

            case .packageConfig:
                if  let account:Unidoc.Account,
                    let package:String = form["package"],
                    let package:Unidoc.Package = .init(package),
                    let update:Swiftinit.PackageConfigEndpoint.Update = .init(from: form)
                {
                    let endpoint:Swiftinit.PackageConfigEndpoint = .init(
                        account: account,
                        package: package,
                        update: update,
                        from: form["from"])

                    return .actor(endpoint)
                }

            case .packageIndex:
                if  let account:Unidoc.Account,
                    let owner:String = form["owner"],
                    let repo:String = form["repo"]
                {
                    return .actor(Swiftinit.PackageIndexEndpoint.init(
                        account: account,
                        owner: owner,
                        repo: repo,
                        from: form["from"]))
                }

            case .packageIndexTag:
                if  let package:String = form["package"],
                    let package:Unidoc.Package = .init(package),
                    let tag:String = form["tag"]
                {
                    return .actor(Swiftinit.PackageIndexTagEndpoint.init(
                        package: package,
                        tag: tag))
                }

            case .telescope:
                if  let days:String = form["days"],
                    let days:Int = .init(days)
                {
                    return .actor(Swiftinit.SiteConfigEndpoint.telescope(days: days))
                }

            case .uplinkAll:
                return .actor(Swiftinit.GraphActionEndpoint.init(queue: .all))

            case .uplink:
                if  let package:String = form["package"],
                    let package:Unidoc.Package = .init(package),
                    let version:String = form["version"],
                    let version:Unidoc.Version = .init(version)
                {
                    return .actor(Swiftinit.GraphActionEndpoint.init(
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
                    return .actor(Swiftinit.GraphActionEndpoint.init(
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
                    return .actor(Swiftinit.GraphActionEndpoint.init(
                        queue: .one(.init(package: package, version: version),
                            action: .delete),
                        from: form["from"]))
                }

            case .userConfig:
                if  let account:Unidoc.Account,
                    let update:Swiftinit.UserConfigEndpoint.Update = .init(from: form)
                {
                    return .actor(Swiftinit.UserConfigEndpoint.init(
                        account: account,
                        update: update))
                }

            default:
                break
            }

            return nil

        case .multipart(.form_data(boundary: let boundary?)):
            let form:MultipartForm = try .init(splitting: body, on: boundary)

            switch trunk
            {
            case .robots_txt:
                if  let item:MultipartForm.Item = form.first(
                        where: { $0.header.name == "text" })
                {
                    return .actor(Swiftinit.TextUpdateEndpoint.init(text: .init(id: .robots_txt,
                        text: .utf8(item.value))))
                }

            default:
                break
            }

            return nil

        default:
            return nil
        }
    }

    static
    func post(really trunk:String,
        body:consuming [UInt8],
        type:ContentType) throws -> Self?
    {
        guard
        let trunk:Swiftinit.API.Post = .init(trunk)
        else
        {
            return nil
        }

        guard
        case .media(.application(.x_www_form_urlencoded, charset: _)) = type
        else
        {
            return nil
        }

        let query:URI.Query = try .parse(parameters: body)

        let heading:String
        let prompt:String
        let button:String

        switch trunk
        {
        case .unlink:
            heading = "Unlink symbol graph?"
            prompt = """
            Nobody will be able to read the documentation for this version of the package. \
            You can reverse this action by uplinking the symbol graph again.
            """
            button = "Remove documentation"

        case .delete:
            heading = "Delete symbol graph?"
            prompt = """
            Nobody will be able to read the documentation for this version of the package. \
            This action is irreversible!
            """
            button = "It is so ordered"

        case .packageConfig:
            let form:[String: String] = query.parameters.reduce(into: [:])
            {
                $0[$1.key] = $1.value
            }

            guard
            let update:Swiftinit.PackageConfigEndpoint.Update = .init(from: form)
            else
            {
                return nil
            }

            switch update
            {
            case .expires:
                heading = "Refresh package tags?"
                prompt = """
                This package will be added to a priority crawl queue. \
                Submitting this form multiple times will not improve its queue position.
                """
                button = "Refresh tags"

            case .hidden(true):
                heading = "Hide package?"
                prompt = """
                The package will no longer appear in search, or in the activity feed. \
                This will not affect the package’s documentation.
                """
                button = "Hide package"

            case .hidden(false):
                heading = "Unhide package?"
                prompt = """
                The package will appear in search, and in the activity feed.
                """
                button = "Unhide package"

            case .symbol:
                heading = "Rename package?"
                prompt = """
                This will not affect documentation that has already been generated.
                """
                button = "Rename package"

            case .build(_?):
                heading = "Build package?"
                prompt = """
                A builder will select a recent version of the package once one becomes \
                available. If you tag a new release in the meantime, it might build that \
                instead.
                """
                button = "Build package"

            case .build(nil):
                heading = "Cancel build?"
                prompt = """
                You can cancel a build if it has not started yet.
                """
                button = "Cancel build"
            }

        case .userConfig:
            let form:[String: String] = query.parameters.reduce(into: [:])
            {
                $0[$1.key] = $1.value
            }

            guard
            let update:Swiftinit.UserConfigEndpoint.Update = .init(from: form)
            else
            {
                return nil
            }
            switch update
            {
            case .generateKey:
                heading = "Generate API key?"
                prompt = """
                This will invalidate any previously-generated API keys. \
                You cannot undo this action!
                """
                button = "Generate key"
            }

        default:
            return nil
        }

        let really:Swiftinit.ReallyPage = .init(title: heading,
            prompt: prompt,
            button: button,
            action: .init(path: Swiftinit.API[trunk].path, query: query))

        return .syncResource(really)
    }
}
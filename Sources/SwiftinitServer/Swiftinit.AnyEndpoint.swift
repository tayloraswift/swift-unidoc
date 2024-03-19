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

extension Swiftinit
{
    enum AnyEndpoint:Sendable
    {
        case interactive(any InteractiveEndpoint)
        case procedural(any ProceduralEndpoint)
        case stateless(any RenderablePage & Sendable)
        case redirect(String)
        case `static`(Cache<Swiftinit.Asset>.Request)
    }
}
extension Swiftinit.AnyEndpoint
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
        ? .interactive(Swiftinit.ExplanatoryEndpoint<Base.Query>.init(query: endpoint.query))
        : .interactive(Swiftinit.OptimizingEndpoint<Base>.init(base: endpoint,
            etag: parameters.tag))
    }
}
//  GET endpoints
extension Swiftinit.AnyEndpoint
{
    static
    func get(admin trunk:String, _ stem:ArraySlice<String>, tag:MD5?) -> Self?
    {
        if  let action:Swiftinit.AdminPage.Action = .init(rawValue: trunk)
        {
            return .stateless(action)
        }

        switch trunk
        {
        case Swiftinit.AdminPage.Recode.name:
            guard
            let target:String = stem.first
            else
            {
                return .stateless(Swiftinit.AdminPage.Recode.init())
            }

            if  let target:Swiftinit.AdminPage.Recode.Target = .init(rawValue: target)
            {
                return .stateless(target)
            }
            else
            {
                return nil
            }

        case Swiftinit.ReplicaSetPage.name:
            return .interactive(Swiftinit.DashboardEndpoint.replicaSet)

        case Swiftinit.CookiePage.name:
            return .interactive(Swiftinit.DashboardEndpoint.cookie(scramble: false))

        case "robots":
            return .interactive(Swiftinit.TextEditorEndpoint.init(id: .robots_txt))

        case _:
            return nil
        }
    }

    static
    func get(api trunk:String,
        _ stem:ArraySlice<String>,
        with parameters:[(key:String, value:String)]) -> Self?
    {
        guard
        let trunk:Swiftinit.API.Get = .init(trunk)
        else
        {
            return nil
        }

        let parameters:[String: String] = parameters.reduce(into: [:]) { $0[$1.key] = $1.value }

        switch trunk
        {
        case .build:
            if  let package:String = stem.first
            {
                let package:Symbol.Package = .init(package)
                let subject:Unidoc.BuildLatest?

                if  let force:String = parameters["force"]
                {
                    subject = .init(force)
                }
                else
                {
                    subject = nil
                }

                return .interactive(Swiftinit.BuilderEndpoint._latest(subject, of: package))
            }
            else if
                let package:String = parameters["package"],
                let package:Unidoc.Package = .init(package),
                let version:String = parameters["version"],
                let version:Unidoc.Version = .init(version)
            {
                return .interactive(Swiftinit.BuilderEndpoint.edition(.init(
                    package: package,
                    version: version)))
            }

        case .oldest:
            if  let version:String = parameters["until"],
                let version:PatchVersion = .init(version)
            {
                return .interactive(Swiftinit.BuilderEndpoint.oldest(until: version))
            }
        }

        return nil
    }

    static
    func get(asset trunk:String, tag:MD5?) -> Self?
    {
        let asset:Swiftinit.Asset? = .init(trunk)
        return asset.map { .static(.init($0, tag: tag)) }
    }

    static
    func get(auth trunk:String, with parameters:Swiftinit.AuthParameters) -> Self?
    {
        switch trunk
        {
        case "github":
            if  let state:String = parameters.state,
                let code:String = parameters.code
            {
                return .interactive(Swiftinit.LoginEndpoint.init(state: state, code: code))
            }

        case "register":
            if  let token:String = parameters.token
            {
                return .interactive(Swiftinit.RegistrationEndpoint.init(token: token))
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
        let filter:Unidoc.VersionsPredicate

        if  let page:Int = parameters.page
        {
            filter = .tags(limit: 20, page: page, beta: parameters.beta)
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
extension Swiftinit.AnyEndpoint
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
            return .interactive(Swiftinit.AdminEndpoint.perform(action, form))
        }

        switch action
        {
        case Swiftinit.AdminPage.Recode.name:
            if  let target:String = rest.first,
                let target:Swiftinit.AdminPage.Recode.Target = .init(rawValue: target)
            {
                return .interactive(Swiftinit.AdminEndpoint.recode(target))
            }

        case Swiftinit.CookiePage.name:
            return .interactive(Swiftinit.DashboardEndpoint.cookie(scramble: true))

        case _:
            break
        }

        return nil
    }

    static
    func post(api trunk:String,
        body:consuming [UInt8],
        type:ContentType) throws -> Self?
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
                    return .interactive(Swiftinit.PackageAliasEndpoint.init(
                        package: package,
                        alias: .init(alias)))
                }

            case .packageAlign:
                if  let package:String = form["package"],
                    let package:Unidoc.Package = .init(package)
                {
                    return .procedural(Swiftinit.PackageAlignEndpoint.init(
                        package: package,
                        realm: form["realm"],
                        force: form["force"] == "true"))
                }

            case .packageConfig:
                if  let package:String = form["package"],
                    let package:Unidoc.Package = .init(package),
                    let update:Swiftinit.PackageConfigEndpoint.Update = .init(from: form)
                {
                    return .interactive(Swiftinit.PackageConfigEndpoint.init(
                        package: package,
                        update: update))
                }

            case .packageIndex:
                if  let owner:String = form["owner"],
                    let repo:String = form["repo"]
                {
                    return .interactive(Swiftinit.PackageIndexEndpoint.init(
                        owner: owner,
                        repo: repo))
                }

            case .packageIndexTag:
                if  let package:String = form["package"],
                    let package:Unidoc.Package = .init(package),
                    let tag:String = form["tag"]
                {
                    return .interactive(Swiftinit.PackageIndexTagEndpoint.init(
                        package: package,
                        tag: tag))
                }

            case .telescope:
                if  let days:String = form["days"],
                    let days:Int = .init(days)
                {
                    return .interactive(Swiftinit.AdminEndpoint.telescope(days: days))
                }

            case .uplinkAll:
                return .interactive(Swiftinit.GraphActionEndpoint.init(queue: .all))

            case .uplink:
                if  let package:String = form["package"],
                    let package:Unidoc.Package = .init(package),
                    let version:String = form["version"],
                    let version:Unidoc.Version = .init(version)
                {
                    return .interactive(Swiftinit.GraphActionEndpoint.init(
                        queue: .one(.init(package: package, version: version),
                            action: .uplinkRefresh),
                        uri: form["redirect"]))
                }

            case .unlink:
                if  let package:String = form["package"],
                    let package:Unidoc.Package = .init(package),
                    let version:String = form["version"],
                    let version:Unidoc.Version = .init(version)
                {
                    return .interactive(Swiftinit.GraphActionEndpoint.init(
                        queue: .one(.init(package: package, version: version),
                            action: .unlink),
                        uri: form["redirect"]))
                }

            case .delete:
                if  let package:String = form["package"],
                    let package:Unidoc.Package = .init(package),
                    let version:String = form["version"],
                    let version:Unidoc.Version = .init(version)
                {
                    return .interactive(Swiftinit.GraphActionEndpoint.init(
                        queue: .one(.init(package: package, version: version),
                            action: .delete),
                        uri: form["redirect"]))
                }

            case .userConfig:
                //  It is legal to forge the account ID, as this will be checked properly in
                //  ``Swiftinit.UserConfigEndpoint.admit(user:level:)``.
                if  let account:String = form["account"],
                    let account:Unidoc.Account = .init(account),
                    let update:Swiftinit.UserConfigEndpoint.Update = .init(from: form)
                {
                    return .interactive(Swiftinit.UserConfigEndpoint.init(
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
                    return .procedural(Swiftinit.TextUpdateEndpoint.init(
                        text: .init(id: .robots_txt, text: .utf8(item.value))))
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

            default:
                return nil
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

        return .stateless(really)
    }
}

//  PUT endpoints
extension Swiftinit.AnyEndpoint
{
    static
    func put(api trunk:String, type:ContentType) throws -> Self?
    {
        guard
        let trunk:Swiftinit.API.Put = .init(trunk)
        else
        {
            return nil
        }

        switch (trunk, type)
        {
        case (.snapshot, .media(.application(.bson, charset: nil))):
            return .procedural(Swiftinit.GraphStorageEndpoint.placed)

        case (.graph, .media(.application(.bson, charset: nil))):
            return .procedural(Swiftinit.GraphStorageEndpoint.object)

        case (_, _):
            return nil
        }
    }
}

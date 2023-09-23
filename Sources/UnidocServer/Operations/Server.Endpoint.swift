import FNV1
import HTTP
import MD5
import ModuleGraphs
import Multiparts
import Symbols
import UnidocDB
import UnidocPages
import UnidocQueries
import UnidocSelectors
import UnidocRecords
import URI

extension Server
{
    enum Endpoint:Sendable
    {
        case interactive(any InteractiveOperation)
        case stateless(ServerResponse)
        case `static`(Cache<Site.Asset.Get>.Request)
    }
}
//  GET endpoints
extension Server.Endpoint
{
    static
    func get(root:String, rest:ArraySlice<String>, uri:URI, tag:MD5?) -> Self?
    {
        if  let trunk:Int = rest.indices.first
        {
            return .get(root: root,
                trunk: rest[trunk],
                stem: rest[rest.index(after: trunk)...],
                uri: uri,
                tag: tag)
        }
        else
        {
            return .get(root: root, uri: uri, tag: tag)
        }
    }

    private static
    func get(root:String, uri:URI, tag:MD5?) -> Self?
    {
        switch root
        {
        case Site.Admin.root:   return .interactive(Server.Operation.AdminDashboard.status)
        case Site.Login.root:   return .interactive(Server.Operation.Bounce.init())
        case "robots.txt":      return .static(.init(.robots_txt, tag: tag))
        case _:                 return nil
        }
    }

    private static
    func get(root:String, trunk:String, stem:ArraySlice<String>, uri:URI, tag:MD5?) -> Self?
    {
        switch root
        {
        case Site.Admin.root:
            if  let action:Site.Admin.Action = .init(rawValue: trunk)
            {
                return .stateless(.resource(action.rendered()))
            }
            else if trunk == "recode",
                let target:String = stem.first,
                let target:Site.Admin.Recode.Target = .init(rawValue: target)
            {
                return .stateless(.resource(Site.Admin.Recode.init(target: target).rendered()))
            }
            else
            {
                return nil
            }

        case Site.API.root:
            switch Site.API.Get.init(trunk)
            {
            case nil:
                return nil

            case .github?:
                if  let parameters:[(String, String)] = uri.query?.parameters,
                    let operation:Server.Operation.Login = .init(parameters: parameters)
                {
                    return .interactive(operation)
                }

            case .register?:
                if  let parameters:[(String, String)] = uri.query?.parameters,
                    let operation:Server.Operation.Register = .init(parameters: parameters)
                {
                    return .interactive(operation)
                }
            }

        case Site.Asset.root:
            let asset:Site.Asset.Get? = .init(trunk)
            return asset.map { .static(.init($0, tag: tag)) }

        case "sitemaps":
            //  Ignore file extension.
            return .interactive(Server.Operation.SiteMap.init(
                package: .init(trunk.prefix { $0 != "." }),
                uri: uri,
                tag: tag))

        case "reference":
            return .get(legacy: trunk, stem: stem, uri: uri)

        case "learn":
            return .get(legacy: trunk, stem: stem, uri: uri)

        case _:
            break
        }

        var explain:Bool = false
        var hash:FNV24? = nil

        for (key, value):(String, String) in uri.query?.parameters ?? []
        {
            switch key
            {
            case "explain": explain = value == "true"
            case "hash":    hash = .init(value)
            case _:         continue
            }
        }

        switch root
        {
        case Site.Tags.root:
            return .interactive(Server.Operation.Pipeline<PackageEditionsQuery>.init(
                explain: explain,
                query: .init(package: .init(trunk)),
                uri: uri,
                tag: tag))

        case Site.Docs.root:
            return .interactive(Server.Operation.Pipeline<WideQuery>.init(
                explain: explain,
                query: .init(
                    volume: .init(trunk),
                    lookup: .init(stem: stem, hash: hash)),
                uri: uri,
                tag: tag))

        case Site.Guides.root:
            return .interactive(Server.Operation.Pipeline<ThinQuery<Volume.Range>>.init(
                explain: explain,
                query: .init(
                    volume: .init(trunk),
                    lookup: .articles),
                uri: uri,
                tag: tag))

        case "articles":
            return .interactive(Server.Operation.Pipeline<WideQuery>.init(
                explain: explain,
                query: .init(
                    volume: .init(package: "__swiftinit", version: "0.0.0"),
                    lookup: .init(stem: ["Articles", trunk], hash: nil)),
                uri: uri,
                tag: tag))

        case "lunr":
            if  let id:VolumeIdentifier = .init(trunk)
            {
                return .interactive(
                    Server.Operation.Pipeline<SearchIndexQuery<VolumeIdentifier>>.init(
                    explain: explain,
                    query: .init(
                        from: UnidocDatabase.Search.name,
                        tag: tag,
                        id: id),
                    uri: uri,
                    tag: tag))
            }
            else if trunk == "packages.json"
            {
                return .interactive(
                    Server.Operation.Pipeline<SearchIndexQuery<Int32>>.init(
                    explain: explain,
                    query: .init(
                        from: UnidocDatabase.Meta.name,
                        tag: tag,
                        id: 0),
                    uri: uri,
                    tag: tag))
            }
            else
            {
                return nil
            }

        case _:
            return nil
        }
    }

    private static
    func get(
        legacy trunk:String,
        stem:ArraySlice<String>,
        uri:URI) -> Self
    {
        var overload:Symbol.Decl? = nil
        var from:String? = nil

        for (key, value):(String, String) in uri.query?.parameters ?? []
        {
            switch key
            {
            case "overload":    overload = .init(rawValue: value)
            case "from":        from = value
            case _:             continue
            }
        }

        let query:ThinQuery<Volume.Shoot> = .legacy(head: trunk, rest: stem, from: from)

        if  let overload:Symbol.Decl
        {
            return .interactive(Server.Operation.Pipeline<ThinQuery<Symbol.Decl>>.init(
                explain: false,
                query: .init(volume: query.volume, lookup: overload),
                uri: uri))
        }
        else
        {
            return .interactive(Server.Operation.Pipeline<ThinQuery<Volume.Shoot>>.init(
                explain: false,
                query: query,
                uri: uri))
        }
    }
}

//  POST endpoints
extension Server.Endpoint
{
    static
    func post(root:String, rest:ArraySlice<String>, form:AnyForm) -> Self?
    {
        switch root
        {
        case Site.Admin.root:   return .post(admin: rest, form: form)
        case Site.API.root:     return .post(api: rest, form: form)
        case _:                 return nil
        }
    }
}
extension Server.Endpoint
{
    private static
    func post(admin rest:ArraySlice<String>, form:AnyForm) -> Self?
    {
        var rest:ArraySlice<String> = rest

        guard
        let action:String = rest.popFirst()
        else
        {
            return nil
        }

        if  let action:Site.Admin.Action = .init(rawValue: action),
            case .multipart(let form) = form
        {
            return .interactive(Server.Operation.Admin.perform(action, form))
        }
        else if action == "recode",
            let target:String = rest.popFirst(),
            let target:Site.Admin.Recode.Target = .init(rawValue: target)
        {
            return .interactive(Server.Operation.Admin.recode(.init(target: target)))
        }
        else
        {
            return nil
        }
    }

    private static
    func post(api rest:ArraySlice<String>, form:AnyForm) -> Self?
    {
        guard   let trunk:String = rest.first,
                let trunk:Site.API.Post = .init(trunk)
        else
        {
            return nil
        }

        switch (trunk, form)
        {
        case (.index, .urlencoded(let parameters)):
            if  let owner:String = parameters["owner"],
                let repo:String = parameters["repo"]
            {
                return .interactive(Server.Operation._SyncRepository.init(
                    owner: owner,
                    repo: repo))
            }

        case (_, _):
            break
        }

        return nil
    }
}

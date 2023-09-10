import FNV1
import HTTP
import MD5
import ModuleGraphs
import Multiparts
import Symbols
import UnidocDatabase
import UnidocPages
import UnidocQueries
import UnidocSelectors
import UnidocRecords
import URI

extension Server
{
    enum Endpoint:Sendable
    {
        case  stateless(ServerResponse)
        case `static`(Cache<Site.Asset.Get>.Request)
        case  stateful(any StatefulOperation)
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
        case Site.Admin.root:   return .stateful(Admin.status)
        case Site.Login.root:   return .stateful(Bounce.init())
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
            if  let action:Site.Admin.Action = .init(rawValue: trunk),
                let page:Site.Admin.Confirm = .init(action: action)
            {
                return .stateless(.resource(page.rendered()))
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
                    let operation:Login = .init(parameters: parameters)
                {
                    return .stateful(operation)
                }

            case .register?:
                if  let parameters:[(String, String)] = uri.query?.parameters,
                    let operation:Register = .init(parameters: parameters)
                {
                    return .stateful(operation)
                }
            }

        case Site.Asset.root:
            let asset:Site.Asset.Get? = .init(trunk)
            return asset.map { .static(.init($0, tag: tag)) }

        case "sitemaps":
            //  Ignore file extension.
            return .stateful(SiteMap.init(
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
        case Site.Docs.root:
            return .stateful(Pipeline<UnidocDatabase, WideQuery>.init(
                explain: explain,
                query: .init(
                    volume: .init(trunk),
                    lookup: .init(stem: stem, hash: hash)),
                uri: uri,
                tag: tag))

        case Site.Guides.root:
            return .stateful(Pipeline<UnidocDatabase, ThinQuery<Volume.Range>>.init(
                explain: explain,
                query: .init(
                    volume: .init(trunk),
                    lookup: .articles),
                uri: uri,
                tag: tag))

        case "articles":
            return .stateful(Pipeline<UnidocDatabase, WideQuery>.init(
                explain: explain,
                query: .init(
                    volume: .init(package: "__swiftinit", version: "0.0.0"),
                    lookup: .init(stem: ["Articles", trunk], hash: nil)),
                uri: uri,
                tag: tag))

        case "lunr":
            if  let id:VolumeIdentifier = .init(trunk)
            {
                return .stateful(
                    Pipeline<UnidocDatabase, SearchIndexQuery<VolumeIdentifier>>.init(
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
                return .stateful(Pipeline<PackageDatabase, SearchIndexQuery<Int32>>.init(
                    explain: explain,
                    query: .init(
                        from: PackageDatabase.Meta.name,
                        tag: tag,
                        id: 0),
                    uri: uri))
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
            return .stateful(Pipeline<UnidocDatabase, ThinQuery<Symbol.Decl>>.init(
                explain: false,
                query: .init(volume: query.volume, lookup: overload),
                uri: uri))
        }
        else
        {
            return .stateful(Pipeline<UnidocDatabase, ThinQuery<Volume.Shoot>>.init(
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
        if  let action:String = rest.first,
            let action:Site.Admin.Action = .init(rawValue: action),
            case .multipart(let form) = form
        {
            return .stateful(Admin.perform(action, form))
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
                return .stateful(_SyncRepository.init(owner: owner, repo: repo))
            }

        case (_, _):
            break
        }

        return nil
    }
}

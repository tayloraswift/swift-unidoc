import FNV1
import MD5
import Multiparts
import Symbols
import UnidocPages
import UnidocQueries
import UnidocSelectors
import URI

enum AnyOperation:Sendable
{
    case datafile(Cache<Site.Asset>.Request)
    case dataless(any DatalessOperation)
    case database(any DatabaseOperation)
}
extension AnyOperation
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
            return .get(root: root)
        }
    }

    private static
    func get(root:String) -> Self?
    {
        switch root
        {
        case Site.Admin.root:   return .database(AdminOperation.status)
        case _:                 return nil
        }
    }

    private static
    func get(root:String, trunk:String, stem:ArraySlice<String>, uri:URI, tag:MD5?) -> Self?
    {
        switch root
        {
        case Site.Admin.root:
            let action:Site.Action? = .init(rawValue: trunk)
            return action.map { .dataless(ConfirmOperation.init($0)) }

        case Site.Asset.root:
            let asset:Site.Asset? = .init(rawValue: trunk)
            return asset.map { .datafile(.init($0, tag: tag)) }

        case "sitemap":
            return .database(SiteMapOperation.init(package: .init(trunk), uri: uri, tag: tag))

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
            let query:WideQuery = .init(
                for: .init(stem: stem, hash: hash),
                in: .init(trunk))

            return .database(QueryOperation<WideQuery>.init(
                explain: explain,
                query: query,
                uri: uri,
                tag: tag))

        case Site.Guides.root:
            let query:ThinQuery<Selector.Planes> = .init(for: .article, in: .init(trunk))

            return .database(QueryOperation<ThinQuery<Selector.Planes>>.init(
                explain: explain,
                query: query,
                uri: uri,
                tag: tag))

        case Site.NounMaps.root:
            let query:NounMapQuery = .init(zone: .init(trunk), tag: tag)

            return .database(QueryOperation<NounMapQuery>.init(
                explain: explain,
                query: query,
                uri: uri,
                tag: tag))

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

        let query:ThinQuery<Selector.Lexical> = .legacy(head: trunk, rest: stem, from: from)

        if  let overload:Symbol.Decl
        {
            return .database(QueryOperation<ThinQuery<Selector.Precise>>.init(
                explain: false,
                query: .init(for: .init(overload), in: query.zone),
                uri: uri))
        }
        else
        {
            return .database(QueryOperation<ThinQuery<Selector.Lexical>>.init(
                explain: false,
                query: query,
                uri: uri))
        }
    }
}

extension AnyOperation
{
    static
    func post(root:String, rest:ArraySlice<String>, form:MultipartForm?) -> Self?
    {
        guard root == Site.Action.root
        else
        {
            return nil
        }
        if  let action:String = rest.first,
            let action:Site.Action = .init(rawValue: action)
        {
            return .database(AdminOperation.perform(action, form))
        }
        else
        {
            return nil
        }
    }
}

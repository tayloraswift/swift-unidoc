import FNV1
import Multiparts
import Symbols
import UnidocPages
import UnidocQueries
import UnidocSelectors
import URI

enum AnyOperation:Sendable
{
    case datafile(Site.Asset)
    case dataless(any DatalessOperation)
    case database(any DatabaseOperation)
}
extension AnyOperation
{
    static
    func get(root:String, rest:ArraySlice<String>, uri:URI) -> Self?
    {
        if  let trunk:Int = rest.indices.first
        {
            return .get(root: root,
                trunk: rest[trunk],
                stem: rest[rest.index(after: trunk)...],
                uri: uri)
        }
        else
        {
            return .get(root: root)
        }
    }

    private static
    func get(root:String, trunk:String, stem:ArraySlice<String>, uri:URI) -> Self?
    {
        switch root
        {
        case Site.Admin.root:
            if  let action:Site.Action = .init(rawValue: trunk)
            {
                return .dataless(ConfirmOperation.init(action))
            }

        case Site.Asset.root:
            if  let asset:Site.Asset = .init(rawValue: trunk)
            {
                return .datafile(asset)
            }

        case Site.Guides.root:
            return .get(planes: .article, trunk: trunk, stem: stem, uri: uri)

        case Site.Docs.root:
            return .get(planes: .docs, trunk: trunk, stem: stem, uri: uri)

        case "reference":
            return .get(legacy: .docs, trunk: trunk, stem: stem, uri: uri)

        case "learn":
            return .get(legacy: .article, trunk: trunk, stem: stem, uri: uri)

        case _:
            break
        }

        return nil
    }
}
extension AnyOperation
{
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
    func get(planes:Selector.Planes, trunk:String, stem:ArraySlice<String>, uri:URI) -> Self
    {
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

        if  stem.isEmpty
        {
            let query:ThinQuery<Selector.Planes> = .init(for: planes, in: .init(trunk))

            return .database(QueryOperation<ThinQuery<Selector.Planes>>.init(
                explain: explain,
                query: query,
                uri: uri))
        }
        else
        {
            let query:WideQuery = .init(
                for: .init(planes: planes, stem: stem, hash: hash),
                in: .init(trunk))

            return .database(QueryOperation<WideQuery>.init(
                explain: explain,
                query: query,
                uri: uri))
        }
    }
    private static
    func get(
        legacy planes:Selector.Planes,
        trunk:String,
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

        let query:ThinQuery<Selector.Master> = .legacy(
            planes: .docs,
            head: trunk,
            rest: stem,
            from: from)

        if  let overload:Symbol.Decl
        {
            return .database(QueryOperation<ThinQuery<Selector.Decl>>.init(
                explain: false,
                query: .init(for: .symbol(overload), in: query.zone),
                uri: uri))
        }
        else
        {
            return .database(QueryOperation<ThinQuery<Selector.Master>>.init(
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

import FNV1
import UnidocDatabase
import UnidocQueries
import URI

extension Delegate
{
    enum Get:Sendable
    {
        case admin  (Admin)
        case asset  (Asset)
        case db     (DB)
        case legacy (Legacy)
    }
}
extension Delegate.Get
{
    static
    func admin(_ path:ArraySlice<String>) -> Self?
    {
        guard let first:String = path.first
        else
        {
            return .admin(.init(tool: nil))
        }
        if  let tool:Admin.Tool = .init(rawValue: first)
        {
            return .admin(.init(tool: tool))
        }
        else
        {
            return nil
        }
    }
    static
    func asset(_ path:ArraySlice<String>) -> Self?
    {
        if  let first:String = path.first,
            let asset:Asset = .init(first)
        {
            return .asset(asset)
        }
        else
        {
            return nil
        }
    }
    static
    func db(_ planes:DeepQuery.Planes, _ path:ArraySlice<String>, uri:URI) -> Self?
    {
        guard let trunk:String = path.first
        else
        {
            return nil
        }

        var canonical:Bool = true
        var explain:Bool = false
        var hash:FNV24? = nil

        for (key, value):(String, String) in uri.query?.parameters ?? []
        {
            switch key
            {
            case "explain": explain = value == "true"
            case "hash":    hash = .init(value)
            case _:         canonical = false
            }
        }

        return .db(.init(
            canonical: canonical,
            explain: explain,
            query: .init(planes, trunk, path.dropFirst(), hash: hash),
            uri: uri))
    }
    static
    func db(legacy planes:DeepQuery.Planes, _ path:ArraySlice<String>, uri:URI) -> Self?
    {
        guard let first:String = path.first
        else
        {
            return nil
        }

        var overload:String? = nil
        var from:String? = nil

        for (key, value):(String, String) in uri.query?.parameters ?? []
        {
            switch key
            {
            case "overload":    overload = value
            case "from":        from = value
            case _:             continue
            }
        }

        return .legacy(.init(query: .init(legacy: planes, first, path.dropFirst(),
            overload: overload,
            from: from)))
    }
}

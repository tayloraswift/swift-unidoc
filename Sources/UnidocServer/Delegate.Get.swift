import FNV1
import UnidocDatabase
import URI

extension Delegate
{
    enum Get:Sendable
    {
        case admin  (Admin)
        case asset  (Asset)
        case db     (DB)
    }
}
extension Delegate.Get
{
    static
    func admin(_ path:ArraySlice<String>) -> Self?
    {
        if  let first:String = path.first,
            let tool:Admin.Tool = .init(rawValue: first)
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
    func db(_ path:ArraySlice<String>, planes:DeepQuery.Planes, uri:URI) -> Self?
    {
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

        if  let first:String = path.first,
            let query:DeepQuery = .init(planes, first, path.dropFirst(), hash: hash)
        {
            return .db(.init(canonical: canonical, explain: explain, query: query, uri: uri))
        }
        else if path.isEmpty
        {
            return .db(.init(canonical: canonical, explain: explain, query: nil, uri: uri))
        }
        else
        {
            return nil
        }
    }
}

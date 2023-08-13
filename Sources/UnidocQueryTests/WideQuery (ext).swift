import FNV1
import UnidocQueries
import UnidocSelectors

extension WideQuery
{
    init(_ trunk:String, _ stem:ArraySlice<String>, hash:FNV24? = nil)
    {
        self.init(
            for: .init(stem: stem, hash: hash),
            in: .init(trunk))
    }
}

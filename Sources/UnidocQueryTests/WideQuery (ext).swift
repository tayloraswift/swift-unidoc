import FNV1
import UnidocQueries
import UnidocSelectors

extension WideQuery
{
    init(_ trunk:String, _ stem:ArraySlice<String>, hash:FNV24? = nil)
    {
        self.init(volume: .init(trunk), lookup: .init(stem: stem, hash: hash))
    }
}

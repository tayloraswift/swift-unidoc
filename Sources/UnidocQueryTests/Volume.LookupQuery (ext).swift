import FNV1
import UnidocQueries
import UnidocRecords
import UnidocSelectors

extension Volume.LookupQuery
{
    init(_ trunk:String, _ stem:ArraySlice<String>, hash:FNV24? = nil)
    {
        self.init(volume: .init(trunk), lookup: .init(stem: stem, hash: hash))
    }
}

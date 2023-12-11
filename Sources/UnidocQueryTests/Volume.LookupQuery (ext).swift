import FNV1
import UnidocQueries
import UnidocRecords

extension Volume.LookupQuery
{
    init(_ trunk:String, _ stem:ArraySlice<String>, hash:FNV24? = nil)
    {
        self.init(volume: .init(trunk), lookup: .init(path: stem, hash: hash))
    }
}

import FNV1
import UnidocQueries
import UnidocRecords

extension Unidoc.VertexQuery<Unidoc.LookupAdjacent>
{
    init(_ trunk:String, _ stem:ArraySlice<String>, hash:FNV24? = nil)
    {
        self.init(volume: .init(trunk), vertex: .init(path: stem, hash: hash))
    }
}

import FNV1
import UnidocRecords

extension Unidoc.VertexPath
{
    init(casefolding stem:borrowing ArraySlice<String>, hash:FNV24? = nil)
    {
        self.init(casefolded: stem.map { $0.lowercased() } [...], hash: hash)
    }
}

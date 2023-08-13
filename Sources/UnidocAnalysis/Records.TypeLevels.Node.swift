import FNV1
import UnidocRecords

extension Records.TypeLevels
{
    struct Node
    {
        let stem:Record.Stem
        let hash:FNV24?
        var nest:[Node]

        init(stem:Record.Stem, hash:FNV24? = nil, nest:[Node] = [])
        {
            self.stem = stem
            self.hash = hash
            self.nest = nest
        }
    }
}
extension Records.TypeLevels.Node
{
    /// Sorts all the nested nodes within this node’s ``nest`` by last stem component.
    mutating
    func sort()
    {
        self.nest.sort { $0.stem.last < $1.stem.last }
    }
}

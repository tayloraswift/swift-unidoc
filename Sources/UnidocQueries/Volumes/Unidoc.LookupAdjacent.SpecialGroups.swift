import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.LookupAdjacent
{
    enum SpecialGroups
    {
        case `default`(Default)
        case protocols
    }
}
extension Unidoc.LookupAdjacent.SpecialGroups
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        switch self
        {
        case .protocols:
            break

        case .default(let self):
            list.expr { $0[.eq] = (Unidoc.AnyGroup[.id], self.peers) }
            list.expr { $0[.eq] = (Unidoc.AnyGroup[.id], self.topic) }
        }
    }
}

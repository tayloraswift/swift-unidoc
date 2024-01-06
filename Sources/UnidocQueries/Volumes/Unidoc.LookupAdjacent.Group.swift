import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.LookupAdjacent
{
    struct Group
    {
        let id:Mongo.Variable<Unidoc.Group>

        init(id:Mongo.Variable<Unidoc.Group>)
        {
            self.id = id
        }
    }
}
extension Unidoc.LookupAdjacent.Group
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        list.expr { $0[.eq] = (Unidoc.AnyGroup[.id], self.id) }
    }
}

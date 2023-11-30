import BSON
import BSONEncoding
import MongoQL
import Unidoc
import UnidocRecords

extension Volume.LookupAdjacent
{
    struct Group
    {
        let id:Mongo.Variable<Unidoc.Scalar>

        init(id:Mongo.Variable<Unidoc.Scalar>)
        {
            self.id = id
        }
    }
}
extension Volume.LookupAdjacent.Group
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        list.expr { $0[.eq] = (Volume.Group[.id], self.id) }
    }
}

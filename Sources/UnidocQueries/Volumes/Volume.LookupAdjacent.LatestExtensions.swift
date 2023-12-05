import BSON
import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Volume.LookupAdjacent
{
    struct LatestExtensions
    {
        let scope:Mongo.Variable<Unidoc.Scalar>
        let id:Mongo.Variable<Realm>

        init(scope:Mongo.Variable<Unidoc.Scalar>, id:Mongo.Variable<Realm>)
        {
            self.scope = scope
            self.id = id
        }
    }
}
extension Volume.LookupAdjacent.LatestExtensions
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        list.expr
        {
            $0[.and] = .init
            {
                $0.expr
                {
                    $0[.eq] = (Volume.Group[.scope], self.scope)
                }
                $0.expr
                {
                    $0[.eq] = (Volume.Group[.realm], self.id)
                }
            }
        }
    }
}

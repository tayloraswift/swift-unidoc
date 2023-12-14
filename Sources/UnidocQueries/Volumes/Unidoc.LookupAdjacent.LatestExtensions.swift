import BSON
import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.LookupAdjacent
{
    struct LatestExtensions
    {
        let scope:Mongo.Variable<Unidoc.Scalar>
        let id:Mongo.Variable<Unidoc>

        init(scope:Mongo.Variable<Unidoc.Scalar>, id:Mongo.Variable<Unidoc>)
        {
            self.scope = scope
            self.id = id
        }
    }
}
extension Unidoc.LookupAdjacent.LatestExtensions
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

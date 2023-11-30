import BSON
import BSONEncoding
import MongoQL
import Unidoc
import UnidocRecords

extension Volume.LookupAdjacent
{
    struct LatestExtensions
    {
        let scope:Mongo.Variable<Unidoc.Scalar>

        init(scope:Mongo.Variable<Unidoc.Scalar>)
        {
            self.scope = scope
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
                    $0[.eq] = (Volume.Group[.latest], true)
                }
            }
        }
    }
}

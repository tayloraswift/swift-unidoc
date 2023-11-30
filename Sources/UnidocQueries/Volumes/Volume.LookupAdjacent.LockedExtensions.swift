import BSON
import BSONEncoding
import MongoQL
import Unidoc
import UnidocRecords

extension Volume.LookupAdjacent
{
    struct LockedExtensions
    {
        let scope:Mongo.Variable<Unidoc.Scalar>
        let min:Mongo.Variable<Unidoc.Scalar>
        let max:Mongo.Variable<Unidoc.Scalar>

        init(scope:Mongo.Variable<Unidoc.Scalar>,
            min:Mongo.Variable<Unidoc.Scalar>,
            max:Mongo.Variable<Unidoc.Scalar>)
        {
            self.scope = scope
            self.min = min
            self.max = max
        }
    }
}
extension Volume.LookupAdjacent.LockedExtensions
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
                    $0[.gte] = (Volume.Group[.id], self.min)
                }
                $0.expr
                {
                    $0[.lte] = (Volume.Group[.id], self.max)
                }
            }
        }
    }
}

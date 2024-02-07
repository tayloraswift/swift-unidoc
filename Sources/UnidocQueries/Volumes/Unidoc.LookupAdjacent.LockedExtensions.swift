import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.LookupAdjacent
{
    struct LockedExtensions
    {
        let layer:Unidoc.GroupLayer?
        let scope:Mongo.Variable<Unidoc.Scalar>
        let min:Mongo.Variable<BSON.Identifier>
        let max:Mongo.Variable<BSON.Identifier>

        init(
            layer:Unidoc.GroupLayer?,
            scope:Mongo.Variable<Unidoc.Scalar>,
            min:Mongo.Variable<BSON.Identifier>,
            max:Mongo.Variable<BSON.Identifier>)
        {
            self.layer = layer
            self.scope = scope
            self.min = min
            self.max = max
        }
    }
}
extension Unidoc.LookupAdjacent.LockedExtensions
{
    static
    func += (or:inout Mongo.PredicateListEncoder, self:Self)
    {
        or
        {
            $0[.and]
            {
                $0
                {
                    guard
                    let layer:Unidoc.GroupLayer = self.layer
                    else
                    {
                        $0[Unidoc.AnyGroup[.layer]] { $0[.exists] = false }
                        return
                    }

                    $0[.expr] { $0[.eq] = (Unidoc.AnyGroup[.layer], layer) }
                }
                $0
                {
                    $0[.expr] { $0[.eq] = (Unidoc.AnyGroup[.scope], self.scope) }
                }
                $0
                {
                    $0[.expr] { $0[.gte] = (Unidoc.AnyGroup[.id], self.min) }
                }
                $0
                {
                    $0[.expr] { $0[.lte] = (Unidoc.AnyGroup[.id], self.max) }
                }
            }
        }
    }
}

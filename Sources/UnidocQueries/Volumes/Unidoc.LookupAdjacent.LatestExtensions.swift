import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.LookupAdjacent
{
    struct LatestExtensions
    {
        let layer:Unidoc.GroupLayer?
        let scope:Mongo.Variable<Unidoc.Scalar>
        let id:Mongo.Variable<Unidoc.Realm>

        init(
            layer:Unidoc.GroupLayer?,
            scope:Mongo.Variable<Unidoc.Scalar>,
            id:Mongo.Variable<Unidoc.Realm>)
        {
            self.layer = layer
            self.scope = scope
            self.id = id
        }
    }
}
extension Unidoc.LookupAdjacent.LatestExtensions
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
                    //  Alas, it is not as simple as performing an `$eq` match on `null`.
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
                    $0[.expr] { $0[.eq] = (Unidoc.AnyGroup[.realm], self.id) }
                }
            }
        }
    }
}

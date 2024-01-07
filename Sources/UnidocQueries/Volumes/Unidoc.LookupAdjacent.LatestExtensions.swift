import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.LookupAdjacent
{
    struct LatestExtensions
    {
        let layer:Unidoc.GroupLayerPredicate
        let scope:Mongo.Variable<Unidoc.Scalar>
        let id:Mongo.Variable<Unidoc.Realm>

        init(
            layer:Unidoc.GroupLayerPredicate,
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
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        list.expr
        {
            $0[.and] = .init
            {
                $0.expr
                {
                    $0[.eq] = (Unidoc.AnyGroup[.layer], self.layer)
                }
                $0.expr
                {
                    $0[.eq] = (Unidoc.AnyGroup[.scope], self.scope)
                }
                $0.expr
                {
                    $0[.eq] = (Unidoc.AnyGroup[.realm], self.id)
                }
            }
        }
    }
}

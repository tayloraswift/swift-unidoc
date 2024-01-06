import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc
{
    struct LockedExtensionsPredicate
    {
        let layer:GroupLayerPredicate
        let scope:Mongo.Variable<Unidoc.Scalar>
        let min:Mongo.Variable<BSON.Identifier>
        let max:Mongo.Variable<BSON.Identifier>

        init(
            layer:GroupLayerPredicate,
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
extension Unidoc.LockedExtensionsPredicate
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
                    $0[.gte] = (Unidoc.AnyGroup[.id], self.min)
                }
                $0.expr
                {
                    $0[.lte] = (Unidoc.AnyGroup[.id], self.max)
                }
            }
        }
    }
}

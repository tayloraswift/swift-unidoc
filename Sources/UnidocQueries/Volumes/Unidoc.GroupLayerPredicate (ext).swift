import BSON
import MongoQL
import Signatures
import Unidoc
import UnidocRecords

extension Unidoc.GroupLayerPredicate
{
    func adjacent(to group:Mongo.Variable<Unidoc.AnyGroup>) -> Mongo.Expression
    {
        self.layer?.adjacent(to: group) ?? .expr
        {
            $0[.concatArrays] = .init
            {
                $0.append([group[.culture]])

                $0.expr
                {
                    $0[.map] = group.constraints.map { $0[.nominal] }
                }

                for key:Unidoc.AnyGroup.CodingKey
                    in [.conformances, .features, .nested, .subforms, .items]
                {
                    $0.expr
                    {
                        $0[.coalesce] = (group[key], [] as [Never])
                    }
                }

                for passage:Mongo.AnyKeyPath in
                [
                    group[.overview] / Unidoc.Passage[.outlines],
                    group[.details] / Unidoc.Passage[.outlines],
                ]
                {
                    $0.expr
                    {
                        let outlines:Mongo.List<Unidoc.Outline, Mongo.AnyKeyPath> = .init(
                            in: passage)

                        $0[.reduce] = outlines.flatMap(\.scalars)
                    }
                }
            }
        }
    }
}

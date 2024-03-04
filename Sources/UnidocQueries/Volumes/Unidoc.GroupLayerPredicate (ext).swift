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
                    in [.conformances, .features, .nested, .subforms]
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

                $0.expr
                {
                    //  TODO: After we phase out all the legacy topics groups, we should no
                    //  longer need to check the element type.
                    let items:Mongo.List<Unidoc.TopicMember, Mongo.AnyKeyPath> = .init(
                        in: group[.items])

                    $0[.filter] = items.filter
                    {
                        (link:Mongo.Variable<Unidoc.TopicMember>) in Mongo.Expression.expr
                        {
                            $0[.eq] = ("objectId", .expr { $0[.type] = link })
                        }
                    }
                }
            }
        }
    }
}

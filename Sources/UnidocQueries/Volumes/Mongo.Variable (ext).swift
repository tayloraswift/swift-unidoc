import BSON
import MongoQL
import Signatures
import Unidoc
import UnidocRecords

extension Mongo.Variable<Unidoc.Outline>
{
    var scalars:Mongo.Expression
    {
        .expr
        {
            $0[.coalesce] = (self[.scalars], [] as [Never])
        }
    }
}
extension Mongo.Variable<Unidoc.Group>
{
    var scalars:Mongo.Expression
    {
        .expr
        {
            $0[.concatArrays] = .init
            {
                $0.expr
                {
                    let constraints:
                        Mongo.List<GenericConstraint<Unidoc.Scalar?>, Mongo.KeyPath> = .init(
                        in: self[.constraints])

                    $0[.map] = constraints.map { $0[.nominal] }
                }

                for key:T.CodingKey in
                [
                    .conformances,
                    .features,
                    .nested,
                    .subforms,
                ]
                {
                    $0.expr
                    {
                        $0[.coalesce] = (self[key], [] as [Never])
                    }
                }

                $0.append([self[.culture]])

                for passage:Mongo.KeyPath in
                [
                    self[.overview] / Unidoc.Passage[.outlines],
                    self[.details] / Unidoc.Passage[.outlines],
                ]
                {
                    $0.expr
                    {
                        let outlines:Mongo.List<Unidoc.Outline, Mongo.KeyPath> = .init(
                            in: passage)

                        $0[.reduce] = outlines.flatMap(\.scalars)
                    }
                }

                $0.expr
                {
                    let members:Mongo.List<Unidoc.VertexLink, Mongo.KeyPath> = .init(
                        in: self[.members])

                    $0[.filter] = members.filter
                    {
                        (link:Mongo.Variable<Unidoc.VertexLink>) in Mongo.Expression.expr
                        {
                            $0[.eq] = ("objectId", .expr { $0[.type] = link })
                        }
                    }
                }
            }
        }
    }

    var zones:Mongo.Expression
    {
        .expr
        {
            $0[.coalesce] = (self[.zones], [] as [Never])
        }
    }
}
